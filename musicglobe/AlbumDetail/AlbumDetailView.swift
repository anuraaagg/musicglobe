//
//  AlbumDetailView.swift
//  musicglobe
//
//  Album detail screen with track list
//

import SwiftUI

struct AlbumDetailView: View {
  @EnvironmentObject var appState: AppState
  @StateObject private var viewModel: AlbumDetailViewModel
  @Environment(\.dismiss) private var dismiss

  let album: AlbumNode

  init(album: AlbumNode) {
    self.album = album
    _viewModel = StateObject(wrappedValue: AlbumDetailViewModel(albumId: album.albumId))
  }

  var body: some View {
    ZStack {
      // White/light background
      Color(red: 0.98, green: 0.98, blue: 0.98)
        .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 0) {
          // Album Header
          albumHeader
            .padding(.top, 60)
            .padding(.bottom, 30)

          // Track List
          if viewModel.isLoading {
            ProgressView()
              .tint(Color(red: 0.3, green: 0.6, blue: 1.0))
              .padding(.top, 40)
          } else if let error = viewModel.error {
            errorView(error)
          } else {
            trackList
          }
        }
      }

      // Close button
      VStack {
        HStack {
          Spacer()
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 32))
              .foregroundStyle(.black.opacity(0.6), .white.opacity(0.8))
              .symbolRenderingMode(.palette)
          }
          .padding(.trailing, 20)
          .padding(.top, 50)
        }
        Spacer()
      }
    }
    .task {
      await viewModel.loadTracks()
    }
  }

  // MARK: - Album Header
  private var albumHeader: some View {
    VStack(spacing: 20) {
      // Album Art
      if let coverURL = album.coverArtURL {
        AsyncImage(url: coverURL) { phase in
          switch phase {
          case .empty:
            albumPlaceholder
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 280, height: 280)
              .clipShape(RoundedRectangle(cornerRadius: 20))
              .shadow(color: .black.opacity(0.5), radius: 30, y: 15)
          case .failure:
            albumPlaceholder
          @unknown default:
            albumPlaceholder
          }
        }
      } else {
        albumPlaceholder
      }

      // Album Info
      VStack(spacing: 8) {
        Text(album.albumName)
          .font(.system(size: 28, weight: .semibold, design: .default))
          .foregroundColor(.black)
          .multilineTextAlignment(.center)

        Text(album.artistName)
          .font(.system(size: 16, weight: .regular))
          .foregroundColor(.black.opacity(0.6))

        // Stats
        HStack(spacing: 20) {
          StatBadge(icon: "play.fill", value: "\(album.playCount)")
          StatBadge(icon: "calendar", value: album.firstPlayedAt.formatted(.dateTime.month().day()))
          if let genre = album.genreTags.first {
            StatBadge(icon: "music.note", value: genre.capitalized)
          }
        }
        .padding(.top, 8)
      }
      .padding(.horizontal, 30)
    }
  }

  private var albumPlaceholder: some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(
        LinearGradient(
          colors: [
            Color(red: 0.2, green: 0.2, blue: 0.3),
            Color(red: 0.1, green: 0.1, blue: 0.2),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .frame(width: 280, height: 280)
      .overlay {
        Image(systemName: "music.note")
          .font(.system(size: 80))
          .foregroundColor(.white.opacity(0.3))
      }
  }

  // MARK: - Track List
  private var trackList: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("Tracks")
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(.black)
        Spacer()
        Text("\(viewModel.tracks.count) songs")
          .font(.system(size: 13, weight: .regular))
          .foregroundColor(.black.opacity(0.5))
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)

      // Tracks
      VStack(spacing: 0) {
        ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
          TrackRow(
            track: track,
            number: index + 1,
            isPlaying: appState.currentPlayback?.currentTrack == track.name
          )
          .onTapGesture {
            appState.playTrack(track)
          }

          if index < viewModel.tracks.count - 1 {
            Divider()
              .background(Color.black.opacity(0.1))
              .padding(.leading, 60)
          }
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.white)
          .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
    }
  }

  // MARK: - Error View
  private func errorView(_ error: String) -> some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 50))
        .foregroundColor(.orange)

      Text(error)
        .font(.system(size: 16))
        .foregroundColor(.white.opacity(0.7))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Button("Try Again") {
        Task {
          await viewModel.loadTracks()
        }
      }
      .font(.system(size: 16, weight: .semibold))
      .foregroundColor(.white)
      .padding(.horizontal, 32)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
      )
    }
    .padding(.top, 40)
  }
}

// MARK: - Track Row
struct TrackRow: View {
  let track: Track
  let number: Int
  let isPlaying: Bool

  var body: some View {
    HStack(spacing: 16) {
      // Track number or playing indicator
      if isPlaying {
        Image(systemName: "waveform")
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(Color(red: 0.3, green: 0.6, blue: 1.0))
          .frame(width: 24)
      } else {
        Text("\(number)")
          .font(.system(size: 13, weight: .regular))
          .foregroundColor(.black.opacity(0.4))
          .frame(width: 24)
      }

      // Track info
      VStack(alignment: .leading, spacing: 4) {
        Text(track.name)
          .font(.system(size: 16, weight: .regular))
          .foregroundColor(.black)
          .lineLimit(1)
      }

      Spacer()

      // Duration
      Text(track.duration)
        .font(.system(size: 13, weight: .regular))
        .foregroundColor(.black.opacity(0.4))
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
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

#Preview {
  AlbumDetailView(album: .preview)
    .environmentObject(AppState())
}
