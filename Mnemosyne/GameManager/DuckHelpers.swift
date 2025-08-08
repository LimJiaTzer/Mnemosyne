import SwiftUI
import RealityKit
import ARKit

/// A collection of helper functions for creating and placing duck entities.
enum DuckHelpers {
    
    private static let duckEntityName = "rubber_duck"
    
    /// The main function to populate the scene with ducks based on difficulty.
    /// - Parameters:
    ///   - difficulty: The selected game difficulty, which determines the number of ducks.
    ///   - planeAnchors: A collection of all currently detected horizontal plane anchors.
    ///   - bundle: The bundle containing the Reality Composer Pro content.
    /// - Returns: An array of `AnchorEntity` objects, each containing a duck.
    @MainActor
    static func populateDucks(
        difficulty: Difficulty,
        planeAnchors: [PlaneAnchor],
        from bundle: Bundle
    ) async -> [AnchorEntity] {
        
        // Determine the number of ducks to create based on the difficulty.
        let numberOfDucks = duckCount(for: difficulty)
        
        var duckAnchors: [AnchorEntity] = []
        
        // Ensure we have planes to place ducks on.
        guard !planeAnchors.isEmpty else {
            print("Warning: No planes detected. Cannot populate ducks.")
            return []
        }
        
        for _ in 0..<numberOfDucks {
            // Find a random valid transform on one of the detected planes.
            guard let randomTransform = findRandomTransform(on: planeAnchors) else {
                // If we can't find a spot, just continue to the next duck.
                continue
            }
            
            // Create the duck entity at the found transform.
            if let duck = await createDuck(at: randomTransform, from: bundle) {
                duckAnchors.append(duck)
            }
        }
        
        return duckAnchors
    }
    
    /// Determines the number of ducks to create for a given difficulty level.
    private static func duckCount(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy:
            return 5
        case .medium:
            return 8
        case .hard:
            return 12
        }
    }
    
    /// Finds a random position and orientation on any of the provided plane anchors.
    /// - Parameter planeAnchors: An array of `PlaneAnchor`s to choose from.
    /// - Returns: An optional `simd_float4x4` matrix representing a valid transform.
    private static func findRandomTransform(on planeAnchors: [PlaneAnchor]) -> simd_float4x4? {
        // Pick a random plane from the list of detected planes.
        guard let randomPlane = planeAnchors.randomElement() else {
            return nil
        }
        
        // Find a random point within the rectangular bounds of the chosen plane.
        let extent = randomPlane.geometry.extent
        let randomX = Float.random(in: -extent.width / 2 ... extent.width / 2)
        let randomZ = Float.random(in: -extent.height / 2 ... extent.height / 2)
        
        // Create a position vector relative to the plane's anchor.
        let positionInPlane = SIMD3<Float>(randomX, 0, randomZ)
        
        // The final world transform is the position on the plane combined
        // with the plane anchor's own transform in the world.
        let worldTransform = randomPlane.originFromAnchorTransform
        var finalTransform = Transform(matrix: worldTransform)
        finalTransform.translation += positionInPlane
        
        return finalTransform.matrix
    }

    /// Creates a single duck entity at a specific transform with a random orientation.
    @MainActor
    private static func createDuck(at worldTransform: simd_float4x4, from bundle: Bundle) async -> AnchorEntity? {
        guard let duckModel = await loadDuckEntity(from: bundle) else {
            return nil
        }
        
        // Create an anchor to lock the duck to the real world.
        let anchor = AnchorEntity(world: worldTransform)
        
        // Set a random orientation for the duck.
        let randomAngle = Float.random(in: 0...(2 * .pi))
        duckModel.transform.rotation = simd_quatf(angle: randomAngle, axis: [0, 1, 0])
        
        anchor.addChild(duckModel)
        return anchor
    }
    
    /// Asynchronously loads the duck model from a specific content bundle.
    @MainActor
    private static func loadDuckEntity(from bundle: Bundle) async -> ModelEntity? {
        guard let duck = try? await Entity(named: duckEntityName, in: bundle) as? ModelEntity else {
            print("Error: Could not load '\(duckEntityName)' model from content bundle.")
            return nil
        }
        
        duck.scale *= 0.05
        duck.generateCollisionShapes(recursive: true)
        
        return duck
    }
}
