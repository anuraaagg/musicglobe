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
  @State private var gradientOffset: CGSize = .zero
  @State private var grainPhase: Double = 0

  var body: some View {
    ZStack {
      // 1. Deep Black Background
      Color.black
        .ignoresSafeArea()

      // 2. Animated Moving Gradient Glow
      ZStack {
        // Outer glow - shifts position
        Circle()
          .fill(
            RadialGradient(
              colors: [
                Color(red: 0.8, green: 0.9, blue: 0.4).opacity(0.5),
                Color(red: 0.11, green: 0.73, blue: 0.33).opacity(0.25),
                Color.clear,
              ],
              center: .center,
              startRadius: 0,
              endRadius: 350
            )
          )
          .frame(width: 700, height: 700)
          .blur(radius: 100)
          .offset(gradientOffset)

        // Secondary glow - opposite movement
        Circle()
          .fill(
            RadialGradient(
              colors: [
                Color(red: 0.6, green: 0.95, blue: 0.5).opacity(0.4),
                Color.clear,
              ],
              center: .center,
              startRadius: 0,
              endRadius: 200
            )
          )
          .frame(width: 400, height: 400)
          .blur(radius: 80)
          .offset(x: -gradientOffset.width * 0.5, y: -gradientOffset.height * 0.5)

        // Inner core - pulses
        Circle()
          .fill(Color(red: 0.85, green: 0.95, blue: 0.6))
          .frame(width: 200, height: 200)
          .blur(radius: 70)
          .scaleEffect(pulse ? 1.1 : 0.9)
      }

      // 3. Film Grain Overlay
      GrainOverlay(phase: grainPhase)
        .opacity(0.04)
        .blendMode(.overlay)
        .ignoresSafeArea()

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
      // Pulse animation
      withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
        pulse = true
      }
      // Gradient movement animation
      withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
        gradientOffset = CGSize(width: 50, height: 30)
      }
      // Grain animation
      Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        grainPhase = Double.random(in: 0...1000)
      }
    }
  }
}

// MARK: - Film Grain Overlay
struct GrainOverlay: View {
  let phase: Double
  
  var body: some View {
    Canvas { context, size in
      // Generate random noise pattern
      for _ in 0..<Int(size.width * size.height * 0.01) {
        let x = CGFloat.random(in: 0...size.width)
        let y = CGFloat.random(in: 0...size.height)
        let opacity = Double.random(in: 0.3...1.0)
        
        context.fill(
          Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
          with: .color(.white.opacity(opacity))
        )
      }
    }
  }
}

#Preview {
  WelcomeView()
    .environmentObject(AppState())
}
