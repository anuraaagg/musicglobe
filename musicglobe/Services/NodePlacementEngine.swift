//
//  NodePlacementEngine.swift
//  musicglobe
//
//  Algorithm for placing album nodes on the globe
//

import Foundation

class NodePlacementEngine {

  // MARK: - Placement Logic
  func placeNodes(for albums: [AlbumPlayData]) -> [AlbumNode] {
    var nodes: [AlbumNode] = []

    // Sort albums by first played date (oldest first)
    let sortedAlbums = albums.sorted { $0.firstPlayedAt < $1.firstPlayedAt }

    // Calculate date range for latitude mapping
    guard let oldestDate = sortedAlbums.first?.firstPlayedAt,
      let newestDate = sortedAlbums.last?.firstPlayedAt
    else {
      return []
    }

    let dateRange = newestDate.timeIntervalSince(oldestDate)

    // Group albums by genre for longitude clustering
    let genreGroups = groupByGenre(albums: sortedAlbums)

    for (index, album) in sortedAlbums.enumerated() {
      // Calculate latitude based on when first played
      // Older albums → higher latitude (toward north pole)
      let timeSinceOldest = album.firstPlayedAt.timeIntervalSince(oldestDate)
      let normalizedTime = dateRange > 0 ? Float(timeSinceOldest / dateRange) : 0.5
      let latitude = -60.0 + (normalizedTime * 120.0)  // Range: -60° to +60°

      // Calculate longitude based on genre
      let primaryGenre = album.genres.first ?? "unknown"
      let longitude = longitudeForGenre(primaryGenre, in: genreGroups)

      // Add some randomness to avoid perfect clustering
      let latJitter = Float.random(in: -5...5)
      let lonJitter = Float.random(in: -10...10)

      let node = AlbumNode(
        albumId: album.album.id,
        albumName: album.album.name,
        artistName: album.album.artistName,
        coverArtURL: album.album.coverArtURL,
        genreTags: album.genres,
        firstPlayedAt: album.firstPlayedAt,
        playCount: album.playCount,
        latitude: latitude + latJitter,
        longitude: longitude + lonJitter,
        radius: 5.2 + Float.random(in: 0...0.3)  // Slight variation in distance
      )

      nodes.append(node)
    }

    return nodes
  }

  // MARK: - Genre Grouping
  private func groupByGenre(albums: [AlbumPlayData]) -> [String: Int] {
    var genreCounts: [String: Int] = [:]

    for album in albums {
      if let genre = album.genres.first {
        genreCounts[genre, default: 0] += 1
      }
    }

    return genreCounts
  }

  // MARK: - Longitude Mapping by Genre
  private func longitudeForGenre(_ genre: String, in groups: [String: Int]) -> Float {
    let genreLower = genre.lowercased()

    // Map genre families to longitude ranges
    switch genreLower {
    case let g where g.contains("rock"):
      return Float.random(in: -180...(-120))
    case let g where g.contains("pop"):
      return Float.random(in: -120...(-60))
    case let g where g.contains("hip hop"), let g where g.contains("rap"):
      return Float.random(in: -60...0)
    case let g where g.contains("electronic"), let g where g.contains("edm"),
      let g where g.contains("house"):
      return Float.random(in: 0...60)
    case let g where g.contains("jazz"), let g where g.contains("blues"):
      return Float.random(in: 60...120)
    case let g where g.contains("indie"), let g where g.contains("alternative"):
      return Float.random(in: 120...180)
    default:
      return Float.random(in: -180...180)
    }
  }
}
