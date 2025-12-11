//
//  AppState.swift
//  musicglobe
//
//  Central app state manager
//

import Combine
import SwiftUI

@MainActor
class AppState: ObservableObject {
  // MARK: - Spotify Connection
  @Published var isSpotifyConnected: Bool = false
  @Published var userProfile: SpotifyUser?

  // MARK: - Globe Data
  @Published var trackNodes: [TrackNode] = []
  @Published var isLoadingData: Bool = false
  @Published var dataError: String?

  // MARK: - Playback State
  @Published var currentPlayback: UserPlayback?
  @Published var selectedTrack: TrackNode?

  // MARK: - UI State
  @Published var showingTrackDetail: Bool = false
  @Published var showingError: Bool = false

  // MARK: - Services
  let spotifyAuth = SpotifyAuthManager.shared
  let spotifyAPI = SpotifyAPIClient.shared
  let imageCache = ImageCache.shared
  let audioPlayer = AudioPlayerService()

  init() {
    checkSpotifyConnection()
  }

  // MARK: - Methods
  // ... (connection methods same as before) ...

  func checkSpotifyConnection() {
    isSpotifyConnected = spotifyAuth.isAuthenticated
    if isSpotifyConnected {
      Task {
        await loadUserData()
      }
    }
  }

  func connectSpotify() {
    Task {
      do {
        try await spotifyAuth.authenticate()
        isSpotifyConnected = true
        await loadUserData()
      } catch {
        dataError = "Failed to connect to Spotify: \(error.localizedDescription)"
        showingError = true
      }
    }
  }

  func loadUserData() async {
    print("🔄 Starting to load user data (Tracks)...")
    isLoadingData = true
    defer {
      isLoadingData = false
      print("✅ Finished loading user data. Track count: \(trackNodes.count)")
    }

    do {
      // Fetch user profile
      print("📱 Fetching user profile...")
      userProfile = try await spotifyAPI.fetchUserProfile()
      print("✅ Got user profile: \(userProfile?.displayName ?? "Unknown")")

      // Fetch User Playlists to find a source
      print("📂 Fetching user playlists...")
      let playlists = try await spotifyAPI.fetchUserPlaylists()

      var tracks: [TrackPlayData] = []

      if playlists.isEmpty {
        print("⚠️ No playlists found. Falling back to recent history.")
        tracks = try await spotifyAPI.fetchRecentTracks(limit: 50)
      } else {
        // Aggregate tracks from valid playlists until we have enough
        for playlist in playlists.prefix(10) {  // Check first 10 playlists
          if tracks.count >= 100 { break }

          print("📂 Fetching tracks from: \(playlist.name)")
          // Spotify max limit per request is usually 50, so we might need multiple fetches
          // For now we grab top 50 from each playlist to fill our 100 quota
          let playlistTracks = try await spotifyAPI.fetchPlaylistTracks(
            playlistId: playlist.id, limit: 50)

          // Filter out empty/invalid tracks if any
          let validTracks = playlistTracks.filter { !$0.trackName.isEmpty }
          
          let previewCount = validTracks.filter { $0.previewUrl != nil }.count
          print("📊 Playlist '\(playlist.name)': \(previewCount)/\(validTracks.count) have previews")
          
          tracks.append(contentsOf: validTracks)
        }

        // If still minimal data (e.g. all playlists empty), fallback to history
        if tracks.count < 20 {
          print("⚠️ Playlists yielded few tracks. Adding recent history...")
          let history = try await spotifyAPI.fetchRecentTracks(limit: 50)
          tracks.append(contentsOf: history)
        }
      }

      // Cap at 100 nodes
      if tracks.count > 100 {
        tracks = Array(tracks.prefix(100))
      }

      // Shuffle for variety
      tracks.shuffle()

      print("✅ Got \(tracks.count) tracks for globe")

      if tracks.isEmpty {
        print("⚠️ WARNING: No tracks returned!")
        dataError = "No listening history found. Try playing some music on Spotify first!"
        showingError = true
        return
      }

      // Place nodes on globe using TrackPlacementEngine
      print("🌍 Placing nodes on globe...")
      let placementEngine = TrackPlacementEngine()
      trackNodes = placementEngine.placeNodes(for: tracks)
      print("✅ Placed \(trackNodes.count) nodes on globe")

    } catch {
      print("❌ ERROR loading user data: \(error)")

      // Check if it's an auth error (401)
      if let apiError = error as? APIError, case .unauthorized = apiError {
        print("🔄 Auth failed. Disconnecting to allow re-login.")
        isSpotifyConnected = false
        spotifyAuth.logout()  // Ensure tokens are cleared
        return
      }

      dataError = "Failed to load music data: \(error.localizedDescription)"
      showingError = true
    }
  }

  func selectTrack(_ node: TrackNode) {
    selectedTrack = node
    showingTrackDetail = true
  }

  func playTrackFromNode(_ node: TrackNode) {
    // 1. Try playing In-App Preview
    if let previewUrlString = node.previewUrl, let url = URL(string: previewUrlString) {
      print("🎵 Playing preview: \(node.trackName)")
      audioPlayer.play(url: url)
      return
    }

    // 2. Fallback to Spotify App Remote
    print("⚠️ No preview URL. Falling back to Spotify App.")
    Task {
      do {
        try await spotifyAPI.playTrack(uri: node.spotifyUri)
        // Update playback state
        currentPlayback = UserPlayback(
          currentTrack: node.trackName,
          isPlaying: true,
          deviceId: nil,
          progressMs: 0
        )
      } catch {
        dataError = "Failed to play track: \(error.localizedDescription)"
        showingError = true
      }
    }
  }
}
