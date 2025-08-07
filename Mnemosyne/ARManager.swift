import SwiftUI
import ARKit
import RealityKit

/// An observable object that manages the ARKit session and plane detection.
@MainActor
class ARManager: ObservableObject {
    
    // The ARKit session and the plane data provider.
    private let session = ARKitSession()
    private let planeDataProvider = PlaneDetectionProvider(
        alignments: [.horizontal] // We only care about horizontal surfaces like floors and tables.
    )
    
    // A dictionary to store the visual plane entities, using the anchor's ID as the key.
    private var planeEntities: [UUID: Entity] = [:]
    
    // The root entity for all of our AR content.
    let rootEntity = Entity()
    
    /// Starts the ARKit session and begins listening for plane detection updates.
    func startSession() async {
        // To use plane detection, your app's Info.plist must have the
        // "Privacy - Camera Usage Description" key.
        
        do {
            // Start the session with our plane data provider.
            try await session.run([planeDataProvider])
            
            // Listen for updates from the plane provider.
            for await update in planeDataProvider.anchorUpdates {
                self.processPlaneUpdate(update)
            }
        } catch {
            print("ARKit session failed to start. Error: \(error)")
        }
    }
    
    /// Processes updates from the PlaneDetectionProvider to add, update, or remove visual planes.
    private func processPlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
        let anchor = update.anchor
        
        // Find the plane's classification (e.g., floor, table, etc.).
        // We will color the visual plane based on its type.
        let classification = anchor.classification
        
        // Create a new visual entity for the plane.
        let planeEntity = self.createPlaneEntity(for: anchor)
        
        switch update.event {
        case .added:
            // A new plane was detected. Add its visual representation to the scene.
            planeEntities[anchor.id] = planeEntity
            rootEntity.addChild(planeEntity)
            
        case .updated:
            // An existing plane was updated (e.g., its size or position changed).
            // Update the existing entity's properties.
            planeEntities[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
            planeEntities[anchor.id]?.getChild(at: 0)?.scale = SIMD3(x: anchor.geometry.width, y: 1.0, z: anchor.geometry.height)
            
        case .removed:
            // A plane was removed. Remove its visual entity from the scene.
            planeEntities[anchor.id]?.removeFromParent()
            planeEntities.removeValue(forKey: anchor.id)
        }
    }
    
    /// Creates a visual entity to represent a detected plane anchor.
    private func createPlaneEntity(for anchor: PlaneAnchor) -> Entity {
        // Create a mesh resource for the plane's geometry.
        let planeMesh = MeshResource.generatePlane(
            width: anchor.geometry.width,
            depth: anchor.geometry.height
        )
        
        // Create a material for the plane. We'll use a semi-transparent color.
        let planeMaterial = UnlitMaterial(color: anchor.classification.color.withAlphaComponent(0.5))
        
        // Create the final entity with the mesh and material.
        let entity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        
        // Set the entity's transform to match the plane anchor.
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        
        return entity
    }
}

// A helper extension to give each plane classification a distinct color for visualization.
extension PlaneAnchor.Classification {
    var color: UIColor {
        switch self {
        case .ceiling, .door, .wall, .window:
            return .clear // We don't care about these for now.
        case .floor:
            return .blue
        case .seat:
            return .yellow
        case .table:
            return .green
        case .platform:
            return .cyan
        @unknown default:
            return .gray
        }
    }
}
