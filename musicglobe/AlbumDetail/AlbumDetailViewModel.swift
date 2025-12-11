//
//  AlbumDetailViewModel.swift
//  musicglobe
//
//  View model for album detail screen
//

import Combine
import Foundation

@MainActor
class AlbumDetailViewModel: ObservableObject {
  @Published var tracks: [Track] = []
  @Published var isLoading = false
  @Published var error: String?

  private let albumId: String
  private let spotifyAPI = SpotifyAPIClient.shared

  init(albumId: String) {
    self.albumId = albumId
  }

  func loadTracks() async {
    isLoading = true
    error = nil

    do {
      tracks = try await spotifyAPI.fetchAlbumTracks(albumId: albumId)
      isLoading = false
    } catch {
      self.error = error.localizedDescription
      isLoading = false
    }
  }
}
