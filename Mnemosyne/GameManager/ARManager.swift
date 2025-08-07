import SwiftUI
import ARKit
import RealityKit

@MainActor
class ARManager: ObservableObject {
    
    static let shared = ARManager()
    
    private let session = ARKitSession()
    private let planeDataProvider = PlaneDetectionProvider(alignments: [.horizontal])
    
    let rootEntity = Entity()
    private var planeEntities: [UUID: ModelEntity] = [:]
    private var detectedPlanes: [UUID: PlaneAnchor] = [:]
    
    @Published var hasFoundPlanes: Bool = false
    
    var planeAnchors: [PlaneAnchor] {
        return Array(detectedPlanes.values)
    }
    
    private init() {}

    func start() {
        Task {
            do {
                if PlaneDetectionProvider.isSupported {
                    try await session.run([planeDataProvider])
                    
                    for await update in planeDataProvider.anchorUpdates {
                        processPlaneUpdate(update)
                    }
                }
            } catch {
                print("ARKit session failed to start. Error: \(error)")
            }
        }
    }
    
    func stop() {
        session.stop()
        planeEntities.removeAll()
        detectedPlanes.removeAll()
        rootEntity.children.removeAll()
        hasFoundPlanes = false
    }
    
    /// Processes updates from the PlaneDetectionProvider to add, update, or remove visual planes.
    private func processPlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
        let anchor = update.anchor
        
        switch update.event {
        case .added:
            let planeEntity = createPlaneEntity(for: anchor)
            planeEntities[anchor.id] = planeEntity
            detectedPlanes[anchor.id] = anchor
            rootEntity.addChild(planeEntity)
            
            if !hasFoundPlanes {
                hasFoundPlanes = true
            }
            
        case .updated:
            guard let planeEntity = planeEntities[anchor.id] else { return }
            
            detectedPlanes[anchor.id] = anchor
            
            planeEntity.transform = Transform(matrix: anchor.originFromAnchorTransform)
            let newMesh = MeshResource.generatePlane(width: anchor.geometry.extent.width, depth: anchor.geometry.extent.height)
            planeEntity.model?.mesh = newMesh
            planeEntity.collision = CollisionComponent(shapes: [.generateBox(width: anchor.geometry.extent.width, height: 0.02, depth: anchor.geometry.extent.height)])
            
        case .removed:
            planeEntities[anchor.id]?.removeFromParent()
            planeEntities.removeValue(forKey: anchor.id)
            detectedPlanes.removeValue(forKey: anchor.id)
        }
        
        print("ARManager: Number of detected planes = \(detectedPlanes.count)")
    }

    /// Creates a ModelEntity to visualize a PlaneAnchor.
    private func createPlaneEntity(for anchor: PlaneAnchor) -> ModelEntity {
        let planeMesh = MeshResource.generatePlane(width: anchor.geometry.extent.width, depth: anchor.geometry.extent.height)
        let planeMaterial = UnlitMaterial(color: anchor.classification.color.withAlphaComponent(0.5))
        let entity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        entity.collision = CollisionComponent(shapes: [.generateBox(width: anchor.geometry.extent.width, height: 0.02, depth: anchor.geometry.extent.height)])
        return entity
    }
}

fileprivate extension PlaneAnchor.Classification {
    var color: UIColor {
        switch self {
        case .floor: return .systemBlue
        case .table: return .systemGreen
        case .seat: return .systemYellow
        case .wall, .door, .ceiling, .window: return .clear
        case .notAvailable, .unknown, .undetermined: return .systemGray
        @unknown default: return .systemGray
        }
    }
}

