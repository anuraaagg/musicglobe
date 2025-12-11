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
    // Legacy implementation disabled. Use TrackPlacementEngine.
    return []

    /*
    var nodes: [AlbumNode] = []
    
    // Sort albums by first played date (oldest first)
    let sortedAlbums = albums.sorted { $0.firstPlayedAt < $1.firstPlayedAt }
    
    // ... rest of implementation commented out ...
    */
  }

  /*
  // MARK: - Genre Grouping
  private func groupByGenre(albums: [AlbumPlayData]) -> [String: Int] {
    var genreCounts: [String: Int] = [:]

    for album in albums {
      if let genre = album.genreTags.first {
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
  */
}
