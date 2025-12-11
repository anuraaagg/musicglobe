//
//  GlobeView.swift
//  musicglobe
//
//  SwiftUI wrapper for SceneKit globe
//

import SceneKit
import SwiftUI

struct GlobeView: View {
  @EnvironmentObject var appState: AppState
  @StateObject private var viewModel = GlobeViewModel()

  var body: some View {
    Group {
      if !appState.isSpotifyConnected || appState.trackNodes.isEmpty {
        // Show welcome screen if not connected or no data
        WelcomeView()
          .environmentObject(appState)
      } else {
        // Show globe view when we have data
        globeContent
      }
    }
    .onAppear {
      viewModel.setup(with: appState)
    }
    .onChange(of: appState.trackNodes) { _, newNodes in
      viewModel.updateNodes(newNodes)
    }
    .sheet(isPresented: $appState.showingTrackDetail) {
      if let track = appState.selectedTrack {
        TrackDetailView(track: track)
          .environmentObject(appState)
      }
    }
    .alert("Error", isPresented: $appState.showingError) {
      Button("OK") {
        appState.showingError = false
      }
    } message: {
      if let error = appState.dataError {
        Text(error)
      }
    }
  }

  private var globeContent: some View {
    ZStack {
      // White/light background
      Color(red: 0.98, green: 0.98, blue: 0.98)
        .ignoresSafeArea()

      // SceneKit View
      SceneKitView(
        scene: viewModel.globeScene.scene,
        onTap: { point, view in
          viewModel.handleTap(at: point, in: view, appState: appState)
        },
        onDrag: { delta in
          viewModel.handleDrag(delta: delta)
        },
        onPinch: { scale in
          viewModel.handlePinch(scale: scale)
        }
      )
      .ignoresSafeArea()

      // Loading state
      if appState.isLoadingData {
        LoadingView()
      }

      // Now Playing Badge
      VStack {
        Spacer()
        if let playback = appState.currentPlayback, playback.isPlaying {
          NowPlayingBadge(trackName: playback.currentTrack)
            .padding(.bottom, 30)
        }
      }
    }
  }
}

// MARK: - SceneKit UIViewRepresentable
struct SceneKitView: UIViewRepresentable {
  let scene: SCNScene
  let onTap: (CGPoint, SCNView) -> Void
  let onDrag: (CGPoint) -> Void
  let onPinch: (Float) -> Void

  func makeUIView(context: Context) -> SCNView {
    let scnView = SCNView()
    scnView.scene = scene
    scnView.backgroundColor = .clear
    scnView.autoenablesDefaultLighting = false
    scnView.allowsCameraControl = false
    scnView.antialiasingMode = .multisampling4X

    // Add gesture recognizers
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    scnView.addGestureRecognizer(tapGesture)

    let panGesture = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan(_:))
    )
    scnView.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePinch(_:))
    )
    scnView.addGestureRecognizer(pinchGesture)

    context.coordinator.scnView = scnView

    return scnView
  }

  func updateUIView(_ uiView: SCNView, context: Context) {
    // Update if needed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onTap: onTap, onDrag: onDrag, onPinch: onPinch)
  }

  // MARK: - Coordinator
  class Coordinator {
    let onTap: (CGPoint, SCNView) -> Void
    let onDrag: (CGPoint) -> Void
    let onPinch: (Float) -> Void
    weak var scnView: SCNView?

    private var lastPanLocation: CGPoint = .zero

    init(
      onTap: @escaping (CGPoint, SCNView) -> Void,
      onDrag: @escaping (CGPoint) -> Void,
      onPinch: @escaping (Float) -> Void
    ) {
      self.onTap = onTap
      self.onDrag = onDrag
      self.onPinch = onPinch
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
      guard let view = scnView else { return }
      let location = gesture.location(in: view)
      onTap(location, view)
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
      guard let view = gesture.view else { return }

      let location = gesture.location(in: view)

      switch gesture.state {
      case .began:
        lastPanLocation = location
      case .changed:
        let delta = CGPoint(
          x: location.x - lastPanLocation.x,
          y: location.y - lastPanLocation.y
        )
        onDrag(delta)
        lastPanLocation = location
      default:
        break
      }
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
      switch gesture.state {
      case .changed:
        let scale = Float(1.0 / gesture.scale)
        onPinch(scale)
        gesture.scale = 1.0
      default:
        break
      }
    }
  }
}

#Preview {
  GlobeView()
    .environmentObject(AppState())
}
