//
//  GlobeViewModel.swift
//  musicglobe
//
//  View model for globe interaction logic
//

import Combine
import SceneKit
import SwiftUI

@MainActor
class GlobeViewModel: ObservableObject {
  let globeScene = GlobeScene()

  @Published var selectedNodeId: String?
  private var imageLoadTasks: [String: Task<Void, Never>] = [:]

  // MARK: - Setup
  func setup(with appState: AppState) {
    updateNodes(appState.albumNodes)
  }

  // MARK: - Update Nodes
  func updateNodes(_ nodes: [AlbumNode]) {
    globeScene.addAlbumNodes(nodes)

    // Load album cover images
    for node in nodes {
      loadAlbumCover(for: node)
    }
  }

  // MARK: - Load Album Cover
  private func loadAlbumCover(for node: AlbumNode) {
    guard let coverURL = node.coverArtURL else { return }

    // Cancel existing task if any
    imageLoadTasks[node.id]?.cancel()

    let task = Task {
      do {
        if let image = try await ImageCache.shared.image(for: coverURL) {
          await MainActor.run {
            globeScene.updateAlbumCover(nodeId: node.id, image: image)
          }
        }
      } catch {
        print("Failed to load image for \(node.albumName): \(error)")
      }
    }

    imageLoadTasks[node.id] = task
  }

  // MARK: - Gesture Handlers
  func handleTap(at point: CGPoint, in view: SCNView, appState: AppState) {
    if let nodeId = globeScene.hitTest(at: point, in: view) {
      // Deselect previous
      if let previousId = selectedNodeId {
        globeScene.highlightNode(previousId, highlighted: false)
      }

      // Select new node
      selectedNodeId = nodeId
      globeScene.highlightNode(nodeId, highlighted: true)

      // Find album and show detail
      if let album = appState.albumNodes.first(where: { $0.id == nodeId }) {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        appState.selectAlbum(album)
      }
    } else {
      // Tap on empty space - deselect
      if let previousId = selectedNodeId {
        globeScene.highlightNode(previousId, highlighted: false)
        selectedNodeId = nil
      }
    }
  }

  func handleDrag(delta: CGPoint) {
    globeScene.rotateCamera(by: delta)
  }

  func handlePinch(scale: Float) {
    globeScene.zoomCamera(scale: scale)
  }
}
