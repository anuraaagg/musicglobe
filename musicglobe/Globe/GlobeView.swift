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
  @State private var lastScale: CGFloat = 1.0

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
        }
      )
      .gesture(
        MagnificationGesture()
          .onChanged { value in
            let delta = value / lastScale
            lastScale = value
            viewModel.handlePinch(scale: Float(1.0 / delta))
          }
          .onEnded { _ in
            lastScale = 1.0
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
        if let playback = appState.currentPlayback {
          // Show if either Spotify state or local player is active
          // Note: playTrackNode updates both, but let's be safe
          NowPlayingBadge(trackName: playback.currentTrack)
            .environmentObject(appState)
            .padding(.bottom, 30)
            .onTapGesture {
              if let node = appState.playingTrackNode {
                appState.selectTrack(node)
              }
            }
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

  func makeUIView(context: Context) -> SCNView {
    let scnView = SCNView()
    scnView.scene = scene
    scnView.backgroundColor = .clear
    scnView.autoenablesDefaultLighting = false
    scnView.allowsCameraControl = false
    scnView.antialiasingMode = .multisampling4X

    // Explicitly set camera
    if let cameraNode = scene.rootNode.childNode(withName: "MainCamera", recursively: true) {
      scnView.pointOfView = cameraNode
    }

    // Add gesture recognizers
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    tapGesture.delegate = context.coordinator
    scnView.addGestureRecognizer(tapGesture)

    let panGesture = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan(_:))
    )
    panGesture.delegate = context.coordinator
    scnView.addGestureRecognizer(panGesture)

    context.coordinator.scnView = scnView

    return scnView
  }

  func updateUIView(_ uiView: SCNView, context: Context) {
    // Update if needed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onTap: onTap, onDrag: onDrag)
  }

  // MARK: - Coordinator
  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    let onTap: (CGPoint, SCNView) -> Void
    let onDrag: (CGPoint) -> Void
    weak var scnView: SCNView?

    private var lastPanLocation: CGPoint = .zero

    init(
      onTap: @escaping (CGPoint, SCNView) -> Void,
      onDrag: @escaping (CGPoint) -> Void
    ) {
      self.onTap = onTap
      self.onDrag = onDrag
    }

    // Allow gestures to work together (e.g. Pan + Pinch)
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      return true
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
  }
}

#Preview {
  GlobeView()
    .environmentObject(AppState())
}
