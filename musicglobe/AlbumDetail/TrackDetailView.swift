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

  var body: some View {
    ZStack {
      // Background
      Color(red: 0.98, green: 0.98, blue: 0.98)
        .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 30) {
          // Close button
          HStack {
            Spacer()
            Button {
              dismiss()
            } label: {
              Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.black.opacity(0.6), Color.white)
            }
          }
          .padding(.horizontal)
          .padding(.top)

          // Large Album Art
          AsyncImage(url: track.coverArtURL) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Rectangle()
              .fill(Color.gray.opacity(0.1))
              .overlay(ProgressView())
          }
          .frame(width: 300, height: 300)
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .shadow(color: .black.opacity(0.2), radius: 20, y: 10)

          // Track Info
          VStack(spacing: 8) {
            Text(track.trackName)
              .font(.system(size: 28, weight: .bold))
              .foregroundColor(.black)
              .multilineTextAlignment(.center)

            Text(track.artistName)
              .font(.system(size: 20, weight: .medium))
              .foregroundColor(.black.opacity(0.7))

            Text(track.albumName)
              .font(.system(size: 16))
              .foregroundColor(.black.opacity(0.5))
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal)

          // Stats Badges
          HStack(spacing: 15) {
            StatBadge(icon: "clock", value: track.duration)
            StatBadge(icon: "flame.fill", value: "\(track.popularity)")
            StatBadge(icon: "calendar", value: formatDate(track.playedAt))
          }

          // Play Button
          Button {
            appState.playTrackFromNode(track)
          } label: {
            HStack {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 24))
              Text("Play on Spotify")
                .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
              LinearGradient(
                colors: [
                  Color(red: 0.11, green: 0.73, blue: 0.33),
                  Color(red: 0.08, green: 0.6, blue: 0.28),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(red: 0.11, green: 0.73, blue: 0.33).opacity(0.4), radius: 10, y: 5)
          }
          .padding(.horizontal, 40)
          .padding(.top, 20)

          Spacer(minLength: 50)
        }
      }
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
