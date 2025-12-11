//
//  SpotifyModels.swift
//  musicglobe
//
//  Data models for Spotify API responses
//

import Foundation

// MARK: - User Profile
struct SpotifyUser: Codable {
  let id: String
  let displayName: String?
  let email: String?
  let images: [SpotifyImage]?

  enum CodingKeys: String, CodingKey {
    case id
    case displayName = "display_name"
    case email
    case images
  }
}

// MARK: - Album
struct SpotifyAlbum: Codable, Identifiable {
  let id: String
  let name: String
  let artists: [SpotifyArtist]
  let images: [SpotifyImage]
  let releaseDate: String?
  let genres: [String]?

  enum CodingKeys: String, CodingKey {
    case id, name, artists, images, genres
    case releaseDate = "release_date"
  }

  var coverArtURL: URL? {
    images.first?.url
  }

  var artistName: String {
    artists.map { $0.name }.joined(separator: ", ")
  }
}

// MARK: - Artist
struct SpotifyArtist: Codable {
  let id: String
  let name: String
  let genres: [String]?
}

// MARK: - Track
struct Track: Codable, Identifiable {
  let id: String
  let name: String
  let durationMs: Int
  let uri: String
  let previewUrl: String?
  let trackNumber: Int?

  enum CodingKeys: String, CodingKey {
    case id, name, uri
    case durationMs = "duration_ms"
    case previewUrl = "preview_url"
    case trackNumber = "track_number"
  }

  var spotifyUri: String { uri }

  var duration: String {
    let seconds = durationMs / 1000
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}

// MARK: - Image
struct SpotifyImage: Codable {
  let url: URL
  let height: Int?
  let width: Int?
}

// MARK: - Album for tracks (in recently played)
struct TrackAlbum: Codable {
  let id: String
  let name: String
  let images: [SpotifyImage]
  let artists: [SpotifyArtist]
}

// MARK: - Detailed Track (from recently played)
struct DetailedTrack: Codable {
  let id: String
  let name: String
  let artists: [SpotifyArtist]
  let album: TrackAlbum
  let durationMs: Int
  let uri: String
  let popularity: Int

  enum CodingKeys: String, CodingKey {
    case id, name, artists, album, uri, popularity
    case durationMs = "duration_ms"
  }
}

// MARK: - Recently Played
struct RecentlyPlayedResponse: Codable {
  let items: [PlayHistoryItem]
}

struct PlayHistoryItem: Codable {
  let track: DetailedTrack
  let playedAt: String

  enum CodingKeys: String, CodingKey {
    case track
    case playedAt = "played_at"
  }
}

struct SpotifyTrack: Codable {
  let id: String
  let name: String
  let album: SpotifyAlbum
  let durationMs: Int
  let uri: String
  let previewUrl: String?

  enum CodingKeys: String, CodingKey {
    case id, name, album, uri
    case durationMs = "duration_ms"
    case previewUrl = "preview_url"
  }
}

// MARK: - Top Items
struct TopItemsResponse<T: Codable>: Codable {
  let items: [T]
}

// MARK: - Album Details
struct AlbumDetailsResponse: Codable {
  let id: String
  let name: String
  let artists: [SpotifyArtist]
  let images: [SpotifyImage]
  let tracks: TracksResponse
  let releaseDate: String?

  enum CodingKeys: String, CodingKey {
    case id, name, artists, images, tracks
    case releaseDate = "release_date"
  }
}

struct TracksResponse: Codable {
  let items: [Track]
}

// MARK: - Playback State
struct UserPlayback: Codable {
  let currentTrack: String
  let isPlaying: Bool
  let deviceId: String?
  let progressMs: Int
}

struct PlaybackDevice: Codable {
  let id: String
  let isActive: Bool
  let name: String
  let type: String

  enum CodingKeys: String, CodingKey {
    case id
    case isActive = "is_active"
    case name
    case type
  }
}

// MARK: - Album play tracking data
struct AlbumPlayData {
  let albumId: String
  let albumName: String
  let artistName: String
  let coverArtURL: URL?
  let genreTags: [String]
  var firstPlayedAt: Date
  var playCount: Int
}

// MARK: - Recently Played Tracks Response
struct RecentlyPlayedTracksResponse: Codable {
  let items: [PlayHistoryItem]
  let next: String?
  let cursors: Cursors?
  let limit: Int
  let href: String
}

struct Cursors: Codable {
  let after: String?
  let before: String?
}

// MARK: - Track Play Data (intermediate)
struct TrackPlayData {
  let trackId: String
  let trackName: String
  let artistName: String
  let albumName: String
  let albumId: String
  let coverArtURL: URL?
  let genreTags: [String]
  let playedAt: Date
  let durationMs: Int
  let popularity: Int
  let spotifyUri: String
}

// MARK: - Playlist Models
struct PlaylistResponse: Codable {
  let items: [SpotifyPlaylist]
}

struct SpotifyPlaylist: Codable {
  let id: String
  let name: String
  let images: [SpotifyImage]
  let description: String?
}

struct PlaylistTracksResponse: Codable {
  let items: [PlaylistTrackItem]
}

struct PlaylistTrackItem: Codable {
  let track: DetailedTrack
  let addedAt: String

  enum CodingKeys: String, CodingKey {
    case track
    case addedAt = "added_at"
  }
}
