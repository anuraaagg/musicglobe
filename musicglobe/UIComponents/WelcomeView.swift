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
    
    var body: some View {
        ZStack {
            // 1. Deep Black Background
            Color.black
                .ignoresSafeArea()
            
            // 2. Central Glowing Aura (Animated)
            ZStack {
                // Outer glow (Softer, larger)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.8, green: 0.9, blue: 0.4).opacity(0.6), // Lime/Yellow center
                                Color(red: 0.11, green: 0.73, blue: 0.33).opacity(0.3), // Spotify Green mid
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(width: 600, height: 600)
                    .blur(radius: 80)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .opacity(pulse ? 0.8 : 0.6)
                
                // Inner core (Brighter)
                Circle()
                    .fill(Color(red: 0.8, green: 0.95, blue: 0.6))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .scaleEffect(pulse ? 1.05 : 0.95)
            }
            .offset(y: -50) // Slight upward offset to balance with button
            
            // 3. Connect Button at bottom
            VStack {
                Spacer()
                
                if !appState.isSpotifyConnected {
                    Button {
                        appState.connectSpotify()
                    } label: {
                        Text("Connect with Spotify")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.11, green: 0.73, blue: 0.33))
                            )
                            .shadow(color: Color(red: 0.11, green: 0.73, blue: 0.33).opacity(0.5), radius: 20, y: 0)
                    }
                    .padding(.bottom, 60)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else if appState.isLoadingData {
                    // Minimal Loading State
                    VStack(spacing: 15) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)
                        Text("Loading your universe...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            // Start "Breathing" animation
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

#Preview {
  WelcomeView()
    .environmentObject(AppState())
}
