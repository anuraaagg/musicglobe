//
//  SpotifyAuthManager.swift
//  musicglobe
//
//  Spotify authentication using Authorization Code with PKCE
//

import AuthenticationServices
import Combine
import CryptoKit
import Foundation

@MainActor
class SpotifyAuthManager: NSObject, ObservableObject {
  static let shared = SpotifyAuthManager()

  // MARK: - Spotify App Credentials
  private let clientId = "6cb4bfa509364298879c274f72a869b6"  // TODO: Replace with your Client ID
  private let redirectURI = "musicglobe://callback"

  // MARK: - Required Scopes
  private let scopes = [
    "user-read-recently-played",
    "user-top-read",
    "user-library-read",
    "user-read-playback-state",
    "user-modify-playback-state",
  ]

  // MARK: - Auth State
  @Published var isAuthenticated = false
  @Published var accessToken: String?
  @Published var refreshToken: String?

  private var authSession: ASWebAuthenticationSession?
  private var codeVerifier: String?

  // MARK: - Keychain Keys
  private let accessTokenKey = "spotify_access_token"
  private let refreshTokenKey = "spotify_refresh_token"

  override private init() {
    super.init()
    loadTokensFromKeychain()
  }

  // MARK: - Authentication
  func authenticate() async throws {
    // Generate PKCE code verifier and challenge
    let verifier = generateCodeVerifier()
    codeVerifier = verifier
    let challenge = generateCodeChallenge(from: verifier)

    // Build authorization URL
    var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
    components.queryItems = [
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "redirect_uri", value: redirectURI),
      URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
      URLQueryItem(name: "code_challenge_method", value: "S256"),
      URLQueryItem(name: "code_challenge", value: challenge),
    ]

    guard let authURL = components.url else {
      throw AuthError.invalidURL
    }

    // Start authentication session
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      authSession = ASWebAuthenticationSession(
        url: authURL,
        callbackURLScheme: "musicglobe"
      ) { [weak self] callbackURL, error in
        guard let self = self else { return }

        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let callbackURL = callbackURL,
          let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value
        else {
          continuation.resume(throwing: AuthError.missingAuthCode)
          return
        }

        Task {
          do {
            try await self.exchangeCodeForToken(code: code)
            continuation.resume()
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }

      authSession?.presentationContextProvider = self
      authSession?.prefersEphemeralWebBrowserSession = false
      authSession?.start()
    }
  }

  // MARK: - Token Exchange
  private func exchangeCodeForToken(code: String) async throws {
    guard let verifier = codeVerifier else {
      throw AuthError.missingCodeVerifier
    }

    var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let bodyParams = [
      "client_id": clientId,
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": redirectURI,
      "code_verifier": verifier,
    ]

    request.httpBody =
      bodyParams
      .map { "\($0.key)=\($0.value)" }
      .joined(separator: "&")
      .data(using: .utf8)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      throw AuthError.tokenExchangeFailed
    }

    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

    await MainActor.run {
      self.accessToken = tokenResponse.accessToken
      self.refreshToken = tokenResponse.refreshToken
      self.isAuthenticated = true
    }

    saveTokensToKeychain()
  }

  // MARK: - PKCE Helpers
  private func generateCodeVerifier() -> String {
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    return Data(buffer).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
  }

  private func generateCodeChallenge(from verifier: String) -> String {
    guard let data = verifier.data(using: .utf8) else { return "" }
    let hash = SHA256.hash(data: data)
    return Data(hash).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
  }

  // MARK: - Keychain Storage
  private func saveTokensToKeychain() {
    if let accessToken = accessToken {
      KeychainHelper.save(accessToken, for: accessTokenKey)
    }
    if let refreshToken = refreshToken {
      KeychainHelper.save(refreshToken, for: refreshTokenKey)
    }
  }

  private func loadTokensFromKeychain() {
    accessToken = KeychainHelper.load(for: accessTokenKey)
    refreshToken = KeychainHelper.load(for: refreshTokenKey)
    isAuthenticated = accessToken != nil
  }

  func logout() {
    accessToken = nil
    refreshToken = nil
    isAuthenticated = false
    KeychainHelper.delete(for: accessTokenKey)
    KeychainHelper.delete(for: refreshTokenKey)
  }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
  nonisolated func presentationAnchor(for session: ASWebAuthenticationSession)
    -> ASPresentationAnchor
  {
    ASPresentationAnchor()
  }
}

// MARK: - Token Response
private struct TokenResponse: Codable {
  let accessToken: String
  let tokenType: String
  let expiresIn: Int
  let refreshToken: String?
  let scope: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case scope
  }
}

// MARK: - Errors
enum AuthError: LocalizedError {
  case invalidURL
  case missingAuthCode
  case missingCodeVerifier
  case tokenExchangeFailed

  var errorDescription: String? {
    switch self {
    case .invalidURL: return "Invalid authorization URL"
    case .missingAuthCode: return "Missing authorization code"
    case .missingCodeVerifier: return "Missing code verifier"
    case .tokenExchangeFailed: return "Failed to exchange code for token"
    }
  }
}

// MARK: - Keychain Helper
class KeychainHelper {
  static func save(_ value: String, for key: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: data,
    ]

    SecItemDelete(query as CFDictionary)
    SecItemAdd(query as CFDictionary, nil)
  }

  static func load(for key: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
    ]

    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)

    guard let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  static func delete(for key: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
    ]
    SecItemDelete(query as CFDictionary)
  }
}
