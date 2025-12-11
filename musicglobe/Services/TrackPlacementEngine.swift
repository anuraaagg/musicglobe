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

    // Use Fibonacci Sphere algorithm for perfectly even distribution
    // This avoids clustering ("clubbing") regardless of artist or time.

    var nodes: [TrackNode] = []
    let n = Float(tracks.count)
    let goldenRatio = (1.0 + sqrt(Float(5.0))) / 2.0

    for (i, track) in tracks.enumerated() {
      let i_float = Float(i)

      // 1. Calculate y (vertical position) from 1 to -1
      // We add a small offset to avoid the exact poles
      let y = 1.0 - (i_float / (n - 1.0)) * 2.0

      // 2. Calculate radius at this y
      let radius = sqrt(1.0 - y * y)

      // 3. Calculate theta (longitude angle) using golden angle
      let theta = 2.0 * Float.pi * i_float / goldenRatio

      let x = cos(theta) * radius
      let z = sin(theta) * radius

      // Convert Cartesian (x, y, z) to Spherical (Lat, Lon)
      // Latitude: asin(y)
      // Longitude: atan2(z, x)

      let latRad = asin(y)
      let lonRad = atan2(z, x)

      // Convert to Degrees for TrackNode
      let latitude = latRad * (180.0 / Float.pi)
      let longitude = lonRad * (180.0 / Float.pi)

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
