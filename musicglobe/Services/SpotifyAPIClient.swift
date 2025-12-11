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

  /*
  // MARK: - Recently Played
  func fetchRecentlyPlayed(limit: Int = 50) async throws -> [AlbumPlayData] {
    // ... implementation removed for now ...
    return []
  }
  
  // MARK: - Top Albums
  func fetchTopAlbums(limit: Int = 20) async throws -> [AlbumPlayData] {
    // ... implementation removed for now ...
    return []
  }
  */

  // MARK: - Recent Tracks
  func fetchRecentTracks(limit: Int = 50) async throws -> [TrackPlayData] {
    let endpoint = "\(baseURL)/me/player/recently-played?limit=\(limit)"
    let response: RecentlyPlayedTracksResponse = try await makeRequest(endpoint: endpoint)

    // Date formatter for Spotify timestamps
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    return response.items.compactMap { item in
      // Allow duplicates so we show full history (50 nodes)
      // Clumps of the same artist/song will naturally form clusters due to placement logic

      let date = dateFormatter.date(from: item.playedAt) ?? Date()

      return TrackPlayData(
        trackId: item.track.id,
        trackName: item.track.name,
        artistName: item.track.artists.first?.name ?? "Unknown",
        albumName: item.track.album.name,
        albumId: item.track.album.id,
        coverArtURL: item.track.album.images.first?.url,
        genreTags: [],  // Note: Genres require separate artist fetch, skipping for speed
        playedAt: date,
        durationMs: item.track.durationMs,
        popularity: item.track.popularity,
        spotifyUri: item.track.uri
      )
    }
  }

  /*
  // MARK: - Recent Albums (Combined)
  func fetchRecentAlbums() async throws -> [AlbumPlayData] {
      return []
  }
  */

  // MARK: - Album Details
  func fetchAlbumTracks(albumId: String) async throws -> [Track] {
    let endpoint = "\(baseURL)/albums/\(albumId)"
    let response: AlbumDetailsResponse = try await makeRequest(endpoint: endpoint)
    return response.tracks.items
  }

  // MARK: - Playback
  func playTrack(uri: String) async throws {
    guard let accessToken = authManager.accessToken else {
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
      // Fallback: open Spotify app directly with the URI
      if let url = URL(string: uri) {
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

  // MARK: - Playlists
  func fetchUserPlaylists() async throws -> [SpotifyPlaylist] {
    let endpoint = "\(baseURL)/me/playlists?limit=50"
    let response: PlaylistResponse = try await makeRequest(endpoint: endpoint)
    return response.items
  }

  func fetchPlaylistTracks(playlistId: String, limit: Int = 50) async throws -> [TrackPlayData] {
    let endpoint = "\(baseURL)/playlists/\(playlistId)/tracks?limit=\(limit)"
    let response: PlaylistTracksResponse = try await makeRequest(endpoint: endpoint)
    
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    return response.items.compactMap { item in
      let date = dateFormatter.date(from: item.addedAt) ?? Date()
      
      return TrackPlayData(
        trackId: item.track.id,
        trackName: item.track.name,
        artistName: item.track.artists.first?.name ?? "Unknown",
        albumName: item.track.album.name,
        albumId: item.track.album.id,
        coverArtURL: item.track.album.images.first?.url,
        genreTags: [],
        playedAt: date,
        durationMs: item.track.durationMs,
        popularity: item.track.popularity,
        spotifyUri: item.track.uri
      )
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
