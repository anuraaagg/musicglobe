//
//  TrackNode.swift
//  musicglobe
//
//  Model for individual track nodes on the 3D globe
//

import Foundation
import SceneKit

struct TrackNode: Identifiable, Codable, Equatable {
  let id: String
  let trackId: String
  let trackName: String
  let artistName: String
  let albumName: String
  let albumId: String
  let coverArtURL: URL?
  let genreTags: [String]
  let playedAt: Date
  let durationMs: Int
  let popularity: Int  // 0-100 from Spotify
  let spotifyUri: String

  // 3D Position
  var position: SIMD3<Float>

  // Spherical coordinates
  var latitude: Float  // -90 to 90 degrees
  var longitude: Float  // -180 to 180 degrees
  var radius: Float  // Distance from globe center

  // Visual properties
  var nodeSize: Float {
    // Scale based on popularity (0.5x to 1.2x base size)
    let baseSize: Float = 0.7
    let scaleFactor = 0.5 + (Float(popularity) / 200.0)
    return baseSize * scaleFactor
  }

  var glowColor: SIMD3<Float> {
    // Different glow colors based on primary genre
    if let primaryGenre = genreTags.first?.lowercased() {
      switch primaryGenre {
      case let g where g.contains("rock"):
        return SIMD3<Float>(1.0, 0.3, 0.3)  // Red
      case let g where g.contains("pop"):
        return SIMD3<Float>(1.0, 0.4, 0.8)  // Pink
      case let g where g.contains("hip hop"), let g where g.contains("rap"):
        return SIMD3<Float>(0.6, 0.3, 1.0)  // Purple
      case let g where g.contains("electronic"), let g where g.contains("edm"):
        return SIMD3<Float>(0.3, 0.8, 1.0)  // Cyan
      case let g where g.contains("jazz"):
        return SIMD3<Float>(1.0, 0.8, 0.3)  // Gold
      case let g where g.contains("indie"), let g where g.contains("alternative"):
        return SIMD3<Float>(0.5, 1.0, 0.5)  // Green
      default:
        return SIMD3<Float>(0.3, 0.6, 1.0)  // Default blue
      }
    }
    return SIMD3<Float>(0.3, 0.6, 1.0)  // Default blue
  }

  var duration: String {
    let minutes = durationMs / 60000
    let seconds = (durationMs % 60000) / 1000
    return String(format: "%d:%02d", minutes, seconds)
  }

  // MARK: - Initializer
  init(
    id: String = UUID().uuidString,
    trackId: String,
    trackName: String,
    artistName: String,
    albumName: String,
    albumId: String,
    coverArtURL: URL?,
    genreTags: [String],
    playedAt: Date,
    durationMs: Int,
    popularity: Int,
    spotifyUri: String,
    latitude: Float,
    longitude: Float,
    radius: Float = 5.2
  ) {
    self.id = id
    self.trackId = trackId
    self.trackName = trackName
    self.artistName = artistName
    self.albumName = albumName
    self.albumId = albumId
    self.coverArtURL = coverArtURL
    self.genreTags = genreTags
    self.playedAt = playedAt
    self.durationMs = durationMs
    self.popularity = popularity
    self.spotifyUri = spotifyUri
    self.latitude = latitude
    self.longitude = longitude
    self.radius = radius

    // Calculate 3D position from spherical coordinates
    self.position = Self.sphericalToCartesian(
      latitude: latitude,
      longitude: longitude,
      radius: radius
    )
  }

  // MARK: - Coordinate Conversion
  static func sphericalToCartesian(latitude: Float, longitude: Float, radius: Float) -> SIMD3<Float>
  {
    let latRad = latitude * .pi / 180.0
    let lonRad = longitude * .pi / 180.0

    let x = radius * cos(latRad) * cos(lonRad)
    let y = radius * sin(latRad)
    let z = radius * cos(latRad) * sin(lonRad)

    return SIMD3<Float>(x, y, z)
  }
}

// MARK: - Preview Data
extension TrackNode {
  static var preview: TrackNode {
    TrackNode(
      trackId: "preview123",
      trackName: "Get Lucky",
      artistName: "Daft Punk",
      albumName: "Random Access Memories",
      albumId: "album123",
      coverArtURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273"),
      genreTags: ["electronic", "house"],
      playedAt: Date(),
      durationMs: 248000,
      popularity: 85,
      spotifyUri: "spotify:track:preview123",
      latitude: 30.0,
      longitude: 45.0
    )
  }
}
