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
      // Clean Gradient Background - no more liquid blur effect
      LinearGradient(
        colors: [
          Color(red: 0.95, green: 0.93, blue: 0.91),
          Color(red: 0.88, green: 0.86, blue: 0.84),
          Color(red: 0.82, green: 0.78, blue: 0.76),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        // Native sheet grabber indicator
        Capsule()
          .fill(Color.gray.opacity(0.4))
          .frame(width: 36, height: 5)
          .padding(.top, 12)
          .padding(.bottom, 24)

        Spacer()
          .frame(height: 16)

        // Album Art - Large, centered with better sizing
        AsyncImage(url: track.coverArtURL) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .overlay(ProgressView())
        }
        .frame(width: 260, height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 25, y: 12)
        .padding(.bottom, 48)

        // Track Info - Centered with better spacing
        VStack(spacing: 10) {
          Text(track.trackName)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .lineLimit(2)

          Text(track.artistName)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.black.opacity(0.7))

          Text(track.albumName)
            .font(.system(size: 16))
            .foregroundColor(.black.opacity(0.5))
            .lineLimit(1)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 48)

        // Play Button - Solid Spotify Green with proper toggle state
        Button {
          if isThisTrackPlaying {
            appState.audioPlayer.pause()
          } else {
            appState.playTrackFromNode(track)
          }
        } label: {
          HStack(spacing: 12) {
            Image(systemName: isThisTrackPlaying ? "pause.fill" : "play.fill")
              .font(.system(size: 20, weight: .bold))
            Text(playButtonText)
              .font(.system(size: 18, weight: .semibold))
          }
          .foregroundColor(.white)
          .frame(width: 240, height: 56)
          .background(
            Capsule()
              .fill(Color(red: 0.11, green: 0.73, blue: 0.33))
          )
        }
        .padding(.bottom, 20)

        if track.previewUrl == nil {
          Text("Preview unavailable for this track")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }

        Spacer()
          .frame(height: 60)
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
