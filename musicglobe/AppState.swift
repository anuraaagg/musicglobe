//
//  AppState.swift
//  musicglobe
//
//  Central app state manager
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    // MARK: - Spotify Connection
    @Published var isSpotifyConnected: Bool = false
    @Published var userProfile: SpotifyUser?
    
    // MARK: - Globe Data
    @Published var albumNodes: [AlbumNode] = []
    @Published var isLoadingData: Bool = false
    @Published var dataError: String?
    
    // MARK: - Playback State
    @Published var currentPlayback: UserPlayback?
    @Published var selectedAlbum: AlbumNode?
    
    // MARK: - UI State
    @Published var showingAlbumDetail: Bool = false
    @Published var showingError: Bool = false
    
    // MARK: - Services
    let spotifyAuth = SpotifyAuthManager.shared
    let spotifyAPI = SpotifyAPIClient.shared
    let imageCache = ImageCache.shared
    
    init() {
        checkSpotifyConnection()
    }
    
    // MARK: - Methods
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
        isLoadingData = true
        defer { isLoadingData = false }
        
        do {
            // Fetch user profile
            userProfile = try await spotifyAPI.fetchUserProfile()
            
            // Fetch music history and create album nodes
            let albums = try await spotifyAPI.fetchRecentAlbums()
            
            // Place nodes on globe using placement engine
            let placementEngine = NodePlacementEngine()
            albumNodes = placementEngine.placeNodes(for: albums)
            
        } catch {
            dataError = "Failed to load music data: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    func selectAlbum(_ node: AlbumNode) {
        selectedAlbum = node
        showingAlbumDetail = true
    }
    
    func playTrack(_ track: Track) {
        Task {
            do {
                try await spotifyAPI.playTrack(uri: track.spotifyUri)
                // Update playback state
                currentPlayback = UserPlayback(
                    currentTrack: track.name,
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
