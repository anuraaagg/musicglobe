//
//  NowPlayingBadge.swift
//  musicglobe
//
//  Now playing indicator badge
//

import SwiftUI

struct NowPlayingBadge: View {
  let trackName: String
  @State private var isAnimating = false

  var body: some View {
    HStack(spacing: 12) {
      // Animated waveform
      HStack(spacing: 3) {
        ForEach(0..<3) { index in
          Capsule()
            .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
            .frame(width: 3, height: isAnimating ? CGFloat.random(in: 8...16) : 8)
            .animation(
              .easeInOut(duration: 0.5)
                .repeatForever()
                .delay(Double(index) * 0.15),
              value: isAnimating
            )
        }
      }
      .frame(width: 20, height: 16)

      // Track name
      Text(trackName)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.white)
        .lineLimit(1)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(
      Capsule()
        .fill(.ultraThinMaterial)
        .overlay(
          Capsule()
            .stroke(
              Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.5),
              lineWidth: 1
            )
        )
    )
    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    .onAppear {
      isAnimating = true
    }
  }
}

#Preview {
  ZStack {
    Color.black
    NowPlayingBadge(trackName: "Bohemian Rhapsody")
  }
}
