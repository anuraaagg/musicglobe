//
//  GlobeScene.swift
//  musicglobe
//
//  SceneKit-based 3D globe visualization
//

import SceneKit
import UIKit

class GlobeScene {

  let scene: SCNScene
  let globeNode: SCNNode
  let cameraNode: SCNNode
  let nodesContainer: SCNNode

  // New hierarchy nodes
  let autoRotationNode: SCNNode
  let manualRotationNode: SCNNode

  private var albumNodeMap: [String: SCNNode] = [:]

  // MARK: - Initialization
  init() {
    scene = SCNScene()

    // 1. Setup Node Hierarchy
    // root -> autoRotation -> manualRotation -> (globe + cards)

    autoRotationNode = SCNNode()
    manualRotationNode = SCNNode()
    nodesContainer = SCNNode()

    scene.rootNode.addChildNode(autoRotationNode)
    autoRotationNode.addChildNode(manualRotationNode)
    manualRotationNode.addChildNode(nodesContainer)

    // Create invisible globe (just for positioning reference)
    let globeGeometry = SCNSphere(radius: 5.0)
    globeGeometry.segmentCount = 100

    // Invisible material
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.clear
    material.transparency = 0.0
    globeGeometry.materials = [material]

    globeNode = SCNNode(geometry: globeGeometry)
    globeNode.opacity = 0.0

    // Add globe to manual rotation node so it spins with drag
    manualRotationNode.addChildNode(globeNode)

    // Setup camera
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.zNear = 0.1
    cameraNode.camera?.zFar = 100
    cameraNode.camera?.fieldOfView = 60
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    scene.rootNode.addChildNode(cameraNode)

    // Setup lighting
    setupLighting()

    // Start Auto-Rotation
    addGlobeRotation()
  }

  // MARK: - Lighting
  private func setupLighting() {
    // Bright ambient light
    let ambientLight = SCNNode()
    ambientLight.light = SCNLight()
    ambientLight.light?.type = .ambient
    ambientLight.light?.color = UIColor(white: 0.9, alpha: 1.0)
    ambientLight.light?.intensity = 1000
    scene.rootNode.addChildNode(ambientLight)

    // Soft directional light from top
    let topLight = SCNNode()
    topLight.light = SCNLight()
    topLight.light?.type = .directional
    topLight.light?.color = UIColor.white
    topLight.light?.intensity = 500
    topLight.position = SCNVector3(x: 0, y: 10, z: 5)
    topLight.look(at: SCNVector3(0, 0, 0))
    scene.rootNode.addChildNode(topLight)

    // Subtle fill light
    let fillLight = SCNNode()
    fillLight.light = SCNLight()
    fillLight.light?.type = .omni
    fillLight.light?.color = UIColor(white: 0.8, alpha: 1.0)
    fillLight.light?.intensity = 200
    fillLight.position = SCNVector3(x: -5, y: -3, z: 5)
    scene.rootNode.addChildNode(fillLight)
  }

  // MARK: - Container Rotation
  private func addGlobeRotation() {
    // Rotate autoRotationNode continuously
    // 120 seconds per full revolution (Slow and smooth)
    let rotation = SCNAction.repeatForever(
      SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 120)
    )
    autoRotationNode.runAction(rotation)
  }

  // MARK: - Add Track Nodes
  func addTrackNodes(_ nodes: [TrackNode]) {
    // Clear existing nodes
    nodesContainer.childNodes.forEach { $0.removeFromParentNode() }
    albumNodeMap.removeAll()

    for trackNode in nodes {
      let scnNode = createTrackCardNode(for: trackNode)
      nodesContainer.addChildNode(scnNode)
      albumNodeMap[trackNode.id] = scnNode
    }
  }

  // MARK: - Create Track Card Node
  private func createTrackCardNode(for track: TrackNode) -> SCNNode {
    let cardSize: CGFloat = CGFloat(track.nodeSize)
    let plane = SCNPlane(width: cardSize, height: cardSize)

    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white
    material.isDoubleSided = false

    material.ambient.contents = UIColor(white: 0.95, alpha: 1.0)
    material.specular.contents = UIColor(white: 0.3, alpha: 1.0)
    material.shininess = 0.1

    plane.materials = [material]

    let node = SCNNode(geometry: plane)
    node.position = SCNVector3(
      track.position.x,
      track.position.y,
      track.position.z
    )
    node.name = track.id

    node.look(at: SCNVector3(0, 0, 0))

    // Fix orientation: look(at) makes -Z face the target.
    // We want the plane's front (+Z) to face AWAY from center (towards camera).
    // So we rotate it 180 degrees around Y after look(at).
    node.localRotate(by: SCNQuaternion(0, 1, 0, 0))  // Actually SCNNode look(at) usually points -Z.
    // Plane geometry is in XY plane.
    // If we look at 0,0,0, the node's -Z points to 0,0,0.
    // The plane faces +Z. So the plane faces AWAY from 0,0,0. This is actually correct for a globe surface!

    // Add slight random rotation for visual variety (local Z axis)
    let randomTilt = Float.random(in: -0.1...0.1)
    node.eulerAngles.z = randomTilt

    addHoverAnimation(to: node)

    return node
  }

  // MARK: - Update Album Cover
  func updateAlbumCover(nodeId: String, image: UIImage) {
    guard let scnNode = albumNodeMap[nodeId],
      let geometry = scnNode.geometry as? SCNPlane
    else {
      return
    }

    let material = SCNMaterial()
    material.diffuse.contents = image
    material.isDoubleSided = false
    material.multiply.contents = UIColor(white: 0.95, alpha: 1.0)
    geometry.materials = [material]
  }

  // MARK: - Selection
  func selectAlbumNode(node: SCNNode) {
    node.childNode(withName: "selectionBorder", recursively: false)?.removeFromParentNode()

    let borderSize: CGFloat = 0.88
    let border = SCNPlane(width: borderSize, height: borderSize)
    let material = SCNMaterial()
    material.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    material.isDoubleSided = false
    border.materials = [material]

    let borderNode = SCNNode(geometry: border)
    borderNode.name = "selectionBorder"
    borderNode.position = SCNVector3(0, 0, -0.01)

    let pulse = SCNAction.sequence([
      SCNAction.fadeOpacity(to: 0.7, duration: 0.6),
      SCNAction.fadeOpacity(to: 1.0, duration: 0.6),
    ])
    borderNode.runAction(SCNAction.repeatForever(pulse))

    node.addChildNode(borderNode)
  }

  func deselectAlbumNode(node: SCNNode) {
    node.childNode(withName: "selectionBorder", recursively: false)?.removeFromParentNode()
  }

  // MARK: - Highlight Node
  func highlightNode(_ nodeId: String, highlighted: Bool) {
    guard let scnNode = albumNodeMap[nodeId] else { return }

    if highlighted {
      let scaleAction = SCNAction.scale(to: 1.15, duration: 0.3)
      scaleAction.timingMode = .easeOut
      scnNode.runAction(scaleAction)
      selectAlbumNode(node: scnNode)
    } else {
      let scaleAction = SCNAction.scale(to: 1.0, duration: 0.3)
      scaleAction.timingMode = .easeOut
      scnNode.runAction(scaleAction)
      deselectAlbumNode(node: scnNode)
    }
  }

  // MARK: - Hover Animation
  private func addHoverAnimation(to node: SCNNode) {
    let moveUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 2.0)
    moveUp.timingMode = .easeInEaseOut
    let moveDown = moveUp.reversed()
    let sequence = SCNAction.sequence([moveUp, moveDown])
    node.runAction(SCNAction.repeatForever(sequence))
  }

  // MARK: - Camera / Interaction Control
  func rotateCamera(by delta: CGPoint) {
    // Apply rotation only to manualRotationNode
    // This stacks on top of autoRotationNode
    let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(delta.x) * 0.01, z: 0, duration: 0.1)
    let rotationX = SCNAction.rotateBy(x: CGFloat(delta.y) * 0.01, y: 0, z: 0, duration: 0.1)

    manualRotationNode.runAction(rotationY)

    // Limit vertical rotation
    let currentX = manualRotationNode.eulerAngles.x + Float(delta.y) * 0.01
    if abs(currentX) < Float.pi / 2 {
      manualRotationNode.runAction(rotationX)
    }
  }

  func zoomCamera(scale: Float) {
    let newZ = cameraNode.position.z * scale
    let clampedZ = max(10, min(25, newZ))
    cameraNode.position.z = clampedZ
  }

  // MARK: - Hit Testing
  func hitTest(at point: CGPoint, in view: SCNView) -> String? {
    let hits = view.hitTest(point, options: [:])

    for hit in hits {
      if let nodeName = hit.node.name,
        !nodeName.isEmpty,
        albumNodeMap[nodeName] != nil
      {
        return nodeName
      }
    }
    return nil
  }
}
