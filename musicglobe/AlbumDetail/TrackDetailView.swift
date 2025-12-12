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
        // Grabber
        Capsule()
          .fill(Color(white: 0.75))
          .frame(width: 36, height: 5)
          .padding(.top, 24)
          .padding(.bottom, 24)

        // Album Art - Smaller, compact
        AsyncImage(url: track.coverArtURL) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.2))
            .overlay(ProgressView())
        }
        .frame(width: 220, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.12), radius: 15, y: 8)
        .padding(.bottom, 24)

        // Track Info - Compact
        VStack(spacing: 6) {
          Text(track.trackName)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)

          Text(track.artistName)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.secondary)

          Text(track.albumName)
            .font(.system(size: 14))
            .foregroundColor(.secondary.opacity(0.7))
            .lineLimit(1)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 28)

        // Play Button - Neumorphic Soft UI Style
        Button {
          if isThisTrackPlaying {
            appState.togglePlayback()
          } else {
            appState.playTrackFromNode(track)
          }
        } label: {
          HStack(spacing: 10) {
            Image(systemName: isThisTrackPlaying ? "pause.fill" : "play.fill")
              .font(.system(size: 16, weight: .semibold))
            Text(playButtonText)
              .font(.system(size: 17, weight: .medium))
          }
          .foregroundColor(.primary.opacity(0.85))
          .frame(height: 52)
          .padding(.horizontal, 36)
          .background(
            Capsule()
              .fill(Color(white: 0.97))
              .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
              .shadow(color: Color.white.opacity(0.9), radius: 4, x: 0, y: -2)
          )
          .overlay(
            Capsule()
              .stroke(Color.white.opacity(0.6), lineWidth: 1)
          )
          .overlay(
            // Inner shadow effect
            Capsule()
              .stroke(Color.black.opacity(0.04), lineWidth: 1)
              .blur(radius: 1)
              .offset(y: 1)
              .mask(Capsule())
          )
        }

        if track.previewUrl == nil {
          Text("Preview unavailable for this track")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.top, 10)
        }
      }
      .padding(.bottom, 24)
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
