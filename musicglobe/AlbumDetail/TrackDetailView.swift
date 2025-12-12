//
//  TrackDetailView.swift
//  musicglobe
//
//  Detail view for a selected track
//

import SwiftUI

struct TrackDetailView: View {
  let track: TrackNode
  @EnvironmentObject var appState: AppState
  @Environment(\.dismiss) var dismiss

  // Track if this specific track is currently playing (either in-app or via Spotify)
  private var isThisTrackPlaying: Bool {
    let isPreviewPlaying =
      appState.audioPlayer.isPlaying && appState.playingTrackNode?.trackId == track.trackId
    let isSpotifyPlaying =
      appState.currentPlayback?.isPlaying == true
      && appState.playingTrackNode?.trackId == track.trackId
    return isPreviewPlaying || isSpotifyPlaying
  }

  var body: some View {
    ZStack {
      // Clean Liquid Glass Background
      if let url = track.coverArtURL {
        AsyncImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: 80)
            .saturation(0.8)
            .overlay(
              // Clean white frost overlay
              Color.white.opacity(0.45)
            )
            .overlay(
              // Subtle gradient for depth
              LinearGradient(
                colors: [
                  Color.white.opacity(0.3),
                  Color.clear,
                  Color.black.opacity(0.05),
                ],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .ignoresSafeArea()
        } placeholder: {
          // Fallback while loading
          Color(white: 0.95)
            .ignoresSafeArea()
        }
      } else {
        Color(white: 0.95)
          .ignoresSafeArea()
      }

      VStack(spacing: 0) {
        // Native sheet grabber - Apple uses 8pt top padding
        Capsule()
          .fill(Color(white: 0.8))
          .frame(width: 36, height: 5)
          .padding(.top, 8)

        Spacer()
          .frame(minHeight: 32, maxHeight: 60)

        // Album Art - Large, centered
        AsyncImage(url: track.coverArtURL) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .overlay(ProgressView())
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)

        Spacer()
          .frame(height: 32)

        // Track Info - Centered like Apple Music
        VStack(spacing: 8) {
          Text(track.trackName)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)

          Text(track.artistName)
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.secondary)

          Text(track.albumName)
            .font(.system(size: 15))
            .foregroundColor(.secondary.opacity(0.8))
            .lineLimit(1)
        }
        .padding(.horizontal, 40)

        Spacer()
          .frame(minHeight: 32, maxHeight: 48)

        // Play Button - Spotify Green
        Button {
          if isThisTrackPlaying {
            appState.togglePlayback()
          } else {
            appState.playTrackFromNode(track)
          }
        } label: {
          HStack(spacing: 10) {
            Image(systemName: isThisTrackPlaying ? "pause.fill" : "play.fill")
              .font(.system(size: 18, weight: .bold))
            Text(playButtonText)
              .font(.system(size: 17, weight: .semibold))
          }
          .foregroundColor(.white)
          .frame(width: 220, height: 50)
          .background(
            Capsule()
              .fill(Color(red: 0.11, green: 0.73, blue: 0.33))
          )
        }

        if track.previewUrl == nil {
          Text("Preview unavailable for this track")
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .padding(.top, 12)
        }

        Spacer()
          .frame(minHeight: 40, maxHeight: 80)
      }
    }
  }

  // Computed property for button text based on state
  private var playButtonText: String {
    if isThisTrackPlaying {
      return "Pause"
    } else if track.previewUrl != nil {
      return "Play Preview"
    } else {
      return "Play on Spotify"
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: date)
  }
}

// MARK: - Stat Badge
struct StatBadge: View {
  let icon: String
  let value: String

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.system(size: 11))
      Text(value)
        .font(.system(size: 13, weight: .medium))
    }
    .foregroundColor(.black.opacity(0.6))
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .fill(Color.black.opacity(0.05))
    )
  }
}
