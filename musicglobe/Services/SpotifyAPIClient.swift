//
//  SpotifyAPIClient.swift
//  musicglobe
//
//  Spotify Web API client for fetching user data and playback
//

import Foundation
import UIKit

class SpotifyAPIClient {
  static let shared = SpotifyAPIClient()

  private let baseURL = "https://api.spotify.com/v1"
  private let authManager = SpotifyAuthManager.shared

  private init() {}

  // MARK: - User Profile
  func fetchUserProfile() async throws -> SpotifyUser {
    let endpoint = "\(baseURL)/me"
    return try await makeRequest(endpoint: endpoint)
  }

  // MARK: - Recently Played
  func fetchRecentlyPlayed(limit: Int = 50) async throws -> [AlbumPlayData] {
    let endpoint = "\(baseURL)/me/player/recently-played?limit=\(limit)"
    let response: RecentlyPlayedResponse = try await makeRequest(endpoint: endpoint)

    // Group by album and count plays
    var albumMap: [String: AlbumPlayData] = [:]

    for item in response.items {
      let album = item.track.album
      let playedAt = ISO8601DateFormatter().date(from: item.playedAt) ?? Date()

      if var existing = albumMap[album.id] {
        existing.playCount += 1
        if playedAt < existing.firstPlayedAt {
          existing.firstPlayedAt = playedAt
        }
        albumMap[album.id] = existing
      } else {
        albumMap[album.id] = AlbumPlayData(
          album: album,
          firstPlayedAt: playedAt,
          playCount: 1,
          genres: album.genres ?? []
        )
      }
    }

    return Array(albumMap.values)
  }

  // MARK: - Top Albums
  func fetchTopAlbums(limit: Int = 20) async throws -> [AlbumPlayData] {
    // Fetch top artists to get their albums
    let endpoint = "\(baseURL)/me/top/artists?limit=\(limit)&time_range=medium_term"
    let response: TopItemsResponse<SpotifyArtist> = try await makeRequest(endpoint: endpoint)

    // Convert artists to album play data (simplified)
    return response.items.enumerated().map { index, artist in
      let mockAlbum = SpotifyAlbum(
        id: artist.id,
        name: "\(artist.name) - Top Tracks",
        artists: [artist],
        images: [],
        releaseDate: nil,
        genres: artist.genres
      )

      return AlbumPlayData(
        album: mockAlbum,
        firstPlayedAt: Date().addingTimeInterval(-Double(index) * 86400),
        playCount: 20 - index,
        genres: artist.genres ?? []
      )
    }
  }

  // MARK: - Recent Albums (Combined)
  func fetchRecentAlbums() async throws -> [AlbumPlayData] {
    async let recent = fetchRecentlyPlayed()
    async let top = fetchTopAlbums()

    let (recentAlbums, topAlbums) = try await (recent, top)

    // Merge and deduplicate
    var combined: [String: AlbumPlayData] = [:]

    for album in recentAlbums {
      combined[album.album.id] = album
    }

    for album in topAlbums where combined[album.album.id] == nil {
      combined[album.album.id] = album
    }

    return Array(combined.values).sorted { $0.playCount > $1.playCount }
  }

  // MARK: - Album Details
  func fetchAlbumTracks(albumId: String) async throws -> [Track] {
    let endpoint = "\(baseURL)/albums/\(albumId)"
    let response: AlbumDetailsResponse = try await makeRequest(endpoint: endpoint)
    return response.tracks.items
  }

  // MARK: - Playback
  func playTrack(uri: String) async throws {
    guard let accessToken = await authManager.accessToken else {
      throw APIError.unauthorized
    }

    let endpoint = "\(baseURL)/me/player/play"
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "PUT"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = ["uris": [uri]]
    request.httpBody = try JSONEncoder().encode(body)

    let (_, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }

    // 204 = success, 404 = no active device
    if httpResponse.statusCode == 404 {
      // Fallback: open Spotify app
      if let url = URL(
        string: uri.replacingOccurrences(of: "spotify:track:", with: "spotify://track/"))
      {
        await MainActor.run {
          #if os(iOS)
            UIApplication.shared.open(url)
          #endif
        }
      }
    } else if httpResponse.statusCode >= 400 {
      throw APIError.playbackFailed
    }
  }

  // MARK: - Generic Request
  private func makeRequest<T: Decodable>(endpoint: String) async throws -> T {
    guard let accessToken = await authManager.accessToken else {
      throw APIError.unauthorized
    }

    guard let url = URL(string: endpoint) else {
      throw APIError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      if httpResponse.statusCode == 401 {
        throw APIError.unauthorized
      }
      throw APIError.requestFailed(statusCode: httpResponse.statusCode)
    }

    do {
      let decoded = try JSONDecoder().decode(T.self, from: data)
      return decoded
    } catch {
      print("Decoding error: \(error)")
      throw APIError.decodingFailed
    }
  }
}

// MARK: - API Errors
enum APIError: LocalizedError {
  case unauthorized
  case invalidURL
  case invalidResponse
  case requestFailed(statusCode: Int)
  case decodingFailed
  case playbackFailed

  var errorDescription: String? {
    switch self {
    case .unauthorized:
      return "Not authorized. Please connect to Spotify."
    case .invalidURL:
      return "Invalid API URL"
    case .invalidResponse:
      return "Invalid server response"
    case .requestFailed(let code):
      return "Request failed with status code \(code)"
    case .decodingFailed:
      return "Failed to decode response"
    case .playbackFailed:
      return "Failed to start playback. Make sure Spotify is open on a device."
    }
  }
}
