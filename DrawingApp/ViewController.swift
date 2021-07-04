//
//  ViewController.swift
//  DrawingApp
//
//  Created by Alogorist on 26/11/20.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet private weak var drawButton: UIButton!
    
    // MARK: - Variables
    private let configuration = ARWorldTrackingConfiguration()
    
    // MARK: - View Life Cycle
    override func  viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    // MARK: - User Defined Methods
    /// Method to setup scene
    private func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        // sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.session.run(configuration)
    }
    
    /// Method to add 2 vectors
    /// - Parameters:
    ///   - left: Left SCNVector
    ///   - right: Right SCNVector
    /// - Returns: Addition of left and right vector
    private func addVectors(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x,
                              left.y + right.y,
                              left.z + right.z)
    }
    
    /// Method to handle drawing on button highlight
    /// - Parameter currentCameraPosition: Camera position used for drawing
    private func handleDrawing(currentCameraPosition: SCNVector3) {
        if drawButton.isHighlighted {
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
            sphereNode.position = currentCameraPosition
            sceneView.scene.rootNode.addChildNode(sphereNode)
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        } else {
            let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
            pointer.name = "pointer"
            pointer.position = currentCameraPosition
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.name == "pointer" {
                    node.removeFromParentNode()
                }
            }
            sceneView.scene.rootNode.addChildNode(pointer)
            pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        }
    }
}

// MARK: - Extension for ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m34)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentCameraPosition = addVectors(left: orientation, right: location)
        DispatchQueue.main.async {
            self.handleDrawing(currentCameraPosition: currentCameraPosition)
        }
    }
    
}
