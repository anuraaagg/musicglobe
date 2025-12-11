//
//  AlbumNode.swift
//  musicglobe
//
//  Model for album nodes on the 3D globe
//

import Foundation
import SceneKit

struct AlbumNode: Identifiable, Codable, Equatable {
  let id: String
  let albumId: String
  let albumName: String
  let artistName: String
  let coverArtURL: URL?
  let genreTags: [String]
  let firstPlayedAt: Date
  let playCount: Int

  // 3D Position
  var position: SIMD3<Float>

  // Spherical coordinates
  var latitude: Float  // -90 to 90 degrees
  var longitude: Float  // -180 to 180 degrees
  var radius: Float  // Distance from globe center

  // Visual properties
  var nodeSize: Float {
    // Scale based on play count (1.0x to 1.5x)
    let baseSize: Float = 0.15
    let scaleFactor = 1.0 + (min(Float(playCount), 50.0) / 100.0)
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
    return SIMD3<Float>(0.3, 0.6, 1.0)  // Default blue (#4EA8FF)
  }

  // MARK: - Initializer
  init(
    id: String = UUID().uuidString,
    albumId: String,
    albumName: String,
    artistName: String,
    coverArtURL: URL?,
    genreTags: [String],
    firstPlayedAt: Date,
    playCount: Int,
    latitude: Float,
    longitude: Float,
    radius: Float = 5.2
  ) {

    self.id = id
    self.albumId = albumId
    self.albumName = albumName
    self.artistName = artistName
    self.coverArtURL = coverArtURL
    self.genreTags = genreTags
    self.firstPlayedAt = firstPlayedAt
    self.playCount = playCount
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

  // Update position when coordinates change
  mutating func updatePosition() {
    position = Self.sphericalToCartesian(
      latitude: latitude,
      longitude: longitude,
      radius: radius
    )
  }
}

// MARK: - Preview Data
extension AlbumNode {
  static var preview: AlbumNode {
    AlbumNode(
      albumId: "preview123",
      albumName: "Random Access Memories",
      artistName: "Daft Punk",
      coverArtURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273b0b0b0b0b0b0b0b0b0b0b0b0"),
      genreTags: ["electronic", "house"],
      firstPlayedAt: Date(),
      playCount: 42,
      latitude: 30.0,
      longitude: 45.0
    )
  }

  static var previews: [AlbumNode] {
    [
      AlbumNode(
        albumId: "1", albumName: "Abbey Road", artistName: "The Beatles",
        coverArtURL: nil, genreTags: ["rock"], firstPlayedAt: Date(),
        playCount: 50, latitude: 45, longitude: 0),
      AlbumNode(
        albumId: "2", albumName: "Thriller", artistName: "Michael Jackson",
        coverArtURL: nil, genreTags: ["pop"], firstPlayedAt: Date(),
        playCount: 30, latitude: -30, longitude: 90),
      AlbumNode(
        albumId: "3", albumName: "Discovery", artistName: "Daft Punk",
        coverArtURL: nil, genreTags: ["electronic"], firstPlayedAt: Date(),
        playCount: 25, latitude: 0, longitude: -45),
    ]
  }
}
