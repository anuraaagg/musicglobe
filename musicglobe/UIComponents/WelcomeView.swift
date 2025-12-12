//
//  WelcomeView.swift
//  musicglobe
//
//  Glassmorphism welcome screen
//

import SwiftUI

struct WelcomeView: View {
  @EnvironmentObject var appState: AppState
  @State private var isAnimating = false
  @State private var pulse = false
  @State private var dragOffset: CGSize = .zero
  @State private var pulseGradient = false

  var body: some View {
    ZStack {
      // 1. Deep Black Background
      Color.black
        .ignoresSafeArea()

      // 2. Central Glowing Aura (Animated)
      ZStack {
        // Outer glow
        Circle()
          .fill(
            RadialGradient(
              colors: [
                Color(red: 0.8, green: 0.9, blue: 0.4).opacity(0.6),  // Lime/Yellow center
                Color(red: 0.11, green: 0.73, blue: 0.33).opacity(0.3),  // Spotify Green mid
                Color.clear,
              ],
              center: .center,
              startRadius: 0,
              endRadius: 300
            )
          )
          .frame(width: 600, height: 600)
          .blur(radius: 80)

        // Inner core
        Circle()
          .fill(Color(red: 0.8, green: 0.95, blue: 0.6))
          .frame(width: 250, height: 250)
          .blur(radius: 60)
          .scaleEffect(pulse ? 1.05 : 0.95)
      }

      // 3. Main Content
      VStack {
        if !appState.isSpotifyConnected {
          Spacer()

          Button {
            appState.connectSpotify()
          } label: {
            HStack(spacing: 12) {
              Image(systemName: "music.note")
                .font(.system(size: 18, weight: .medium))
              Text("Connect with Spotify")
                .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.primary.opacity(0.85))
            .frame(height: 56)
            .padding(.horizontal, 32)
            .background(
              // Neumorphic Soft UI background
              Capsule()
                .fill(Color(white: 0.96))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .shadow(color: Color.white.opacity(0.95), radius: 6, x: 0, y: -3)
            )
            .overlay(
              Capsule()
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
            .overlay(
              // Inner shadow effect
              Capsule()
                .stroke(Color.black.opacity(0.03), lineWidth: 1)
                .blur(radius: 1)
                .offset(y: 1)
                .mask(Capsule())
            )
          }
          .accessibilityLabel("Connect with Spotify")
          .accessibilityHint("Double tap to sign in with your Spotify account")
          .offset(dragOffset)
          .gesture(
            DragGesture()
              .onChanged { value in
                dragOffset = value.translation
              }
              .onEnded { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                  dragOffset = .zero
                }
              }
          )

          Spacer()

        } else if appState.isLoadingData {
          Spacer()
          VStack(spacing: 20) {
            ProgressView()
              .tint(.white)
              .scaleEffect(1.5)
            Text("Loading your universe...")
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(.white.opacity(0.8))
          }
          Spacer()
        }
      }
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
        pulse = true
      }
      pulseGradient = true
    }
  }
}

#Preview {
  WelcomeView()
    .environmentObject(AppState())
}
