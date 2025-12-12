//
//  NowPlayingBadge.swift
//  musicglobe
//
//  Now playing indicator badge
//

import SwiftUI

struct NowPlayingBadge: View {
  let trackName: String
  @EnvironmentObject var appState: AppState
  @State private var isAnimating = false

  var body: some View {
    HStack(spacing: 12) {
      // Controls (Left side or Right? Typical is Left or Right. Screenshot has text centered?
      // User style: "liquid glass".
      // Let's put visualizer left, Text middle, Play/Pause right.

      // Animated waveform
      HStack(spacing: 3) {
        ForEach(0..<3) { index in
          Capsule()
            .fill(Color.primary)  // Adapt color
            .frame(
              width: 3,
              height: isAnimating && appState.audioPlayer.isPlaying ? CGFloat.random(in: 8...16) : 8
            )
            .animation(
              .easeInOut(duration: 0.5)
                .repeatForever()
                .delay(Double(index) * 0.15),
              value: isAnimating && appState.audioPlayer.isPlaying
            )
        }
      }
      .frame(width: 20, height: 16)

      // Status and Track name - shows "Playing" or "Paused"
      VStack(alignment: .leading, spacing: 2) {
        Text(appState.audioPlayer.isPlaying ? "Playing" : "Paused")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(
            appState.audioPlayer.isPlaying ? Color(red: 0.11, green: 0.73, blue: 0.33) : .secondary)

        Text(trackName)
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.primary)
          .lineLimit(1)
          .truncationMode(.tail)
      }
      .frame(maxWidth: 150)  // Prevent expansion

      // Play/Pause Button
      Button {
        appState.togglePlayback()
      } label: {
        let isPlaying =
          (appState.currentPlayback?.isPlaying == true) || appState.audioPlayer.isPlaying
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
          .font(.system(size: 16))
          .foregroundColor(.primary)
      }

      // Close Button
      Button {
        appState.stopPlayback()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.secondary)
      }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 14)
    .background(
      Capsule()
        .fill(.regularMaterial)  // Stronger glass
        .overlay(
          // Liquid Glass Gloss
          LinearGradient(
            colors: [.white.opacity(0.6), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .mask(Capsule())
        )
        .overlay(
          Capsule()
            .stroke(
              LinearGradient(
                colors: [.white.opacity(0.8), .black.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
    )
    .onAppear {
      isAnimating = true
    }
  }
}

#Preview {
  ZStack {
    Color.white
    NowPlayingBadge(trackName: "Bohemian Rhapsody")
      .environmentObject(AppState())
  }
}
