//
//  SpotifyConnectBanner.swift
//  musicglobe
//
//  Banner for connecting to Spotify
//

import SwiftUI

struct SpotifyConnectBanner: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    Button {
      appState.connectSpotify()
    } label: {
      HStack(spacing: 12) {
        Image(systemName: "music.note.list")
          .font(.system(size: 20, weight: .semibold))

        Text("Connect to Spotify")
          .font(.system(size: 16, weight: .semibold))

        Spacer()

        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
      }
      .foregroundColor(.white)
      .padding(.horizontal, 24)
      .padding(.vertical, 16)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [
                Color(red: 0.11, green: 0.73, blue: 0.33),
                Color(red: 0.09, green: 0.6, blue: 0.27),
              ],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      )
      .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
    .padding(.horizontal, 20)
    .padding(.top, 50)
  }
}

#Preview {
  ZStack {
    Color.black
    SpotifyConnectBanner()
      .environmentObject(AppState())
  }
}
