//
//  LoadingView.swift
//  musicglobe
//
//  Loading state view
//

import SwiftUI

struct LoadingView: View {
  @State private var isAnimating = false

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 24) {
        // Animated globe icon
        ZStack {
          Circle()
            .stroke(
              LinearGradient(
                colors: [
                  Color(red: 0.3, green: 0.6, blue: 1.0),
                  Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.3),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 3
            )
            .frame(width: 60, height: 60)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))

          Image(systemName: "globe")
            .font(.system(size: 30))
            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 1.0))
        }

        Text("Loading your music globe...")
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.white)
      }
      .padding(40)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(.ultraThinMaterial)
      )
    }
    .onAppear {
      withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
        isAnimating = true
      }
    }
  }
}

#Preview {
  LoadingView()
}
