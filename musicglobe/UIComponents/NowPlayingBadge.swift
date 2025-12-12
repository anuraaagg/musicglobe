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

      // Track name
      Text(trackName)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.primary)  // Readable on white/light
        .lineLimit(1)

      Spacer(minLength: 8)

      // Play/Pause Button
      Button {
        appState.audioPlayer.toggle()
      } label: {
        Image(systemName: appState.audioPlayer.isPlaying ? "pause.fill" : "play.fill")
          .font(.system(size: 16))
          .foregroundColor(.primary)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(
      Capsule()
        .fill(.ultraThinMaterial)
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
