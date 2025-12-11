//
//  TrackPlacementEngine.swift
//  musicglobe
//
//  Calculates 3D positions for individual track nodes on the globe.
//  Uses timeline (latitude) and artist clustering (longitude) for layout.
//

import Foundation
import SceneKit

class TrackPlacementEngine {

  /// Places track nodes on the globe based on metadata
  /// - Parameter tracks: List of track play data
  /// - Returns: Positioned TrackNodes
  func placeNodes(for tracks: [TrackPlayData]) -> [TrackNode] {
    guard !tracks.isEmpty else { return [] }

    // 1. Sort by time (Most recent first)
    // We want the listening history to flow from top (newest) to bottom (oldest)
    // or wrap around nicely
    let sortedTracks = tracks.sorted { $0.playedAt > $1.playedAt }  // Newest first

    var nodes: [TrackNode] = []

    // 2. Identify Artist Clusters
    // We'll assign each unique artist a specific longitude "slice" or anchor point
    // to keep their songs somewhat grouped horizontally.
    let artistNames = Set(sortedTracks.map { $0.artistName })
    var artistAngles: [String: Float] = [:]

    // Distribute artists randomly around the equator (0-360 degrees) or use hash
    for (index, artist) in artistNames.enumerated() {
      // Pseudorandom consistent angle based on name hash
      let hash = abs(artist.hashValue) % 360
      artistAngles[artist] = Float(hash) - 180.0  // -180 to 180 range
    }

    // 3. Calculate positions
    for (index, track) in sortedTracks.enumerated() {
      // Latitude: Time based
      // Map index 0 (newest) -> Top Hemisphere (+degrees)
      // Map index N (oldest) -> Bottom Hemisphere (-degrees)
      // Range: -70 to +70 (avoiding distinct poles)

      let progress = Float(index) / Float(max(sortedTracks.count - 1, 1))
      let latitude = 70.0 - (progress * 140.0)  // 70 down to -70

      // Longitude: Artist based + Random jitter
      // Get base angle for artist
      let baseAngle = artistAngles[track.artistName] ?? 0.0

      // Add jitter so tracks by same artist don't stack exactly on top of each other
      // Jitter range: +/- 15 degrees
      let jitter = Float.random(in: -15...15)
      let longitude = baseAngle + jitter

      // Create Node
      let node = TrackNode(
        trackId: track.trackId,
        trackName: track.trackName,
        artistName: track.artistName,
        albumName: track.albumName,
        albumId: track.albumId,
        coverArtURL: track.coverArtURL,
        genreTags: track.genreTags,
        playedAt: track.playedAt,
        durationMs: track.durationMs,
        popularity: track.popularity,
        spotifyUri: track.spotifyUri,
        latitude: latitude,
        longitude: longitude
      )

      nodes.append(node)
    }

    return nodes
  }
}
