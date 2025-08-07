import SwiftUI
import RealityKit
import RealityKitContent

// A helper struct to hold the data for each duck's placement.
struct DuckPlacement {
    let position: SIMD3<Float>
    let orientation: simd_quatf
}

struct ImmersiveView: View {
    // A state variable to hold the loaded duck entities.
    @State private var duckEntities: [Entity] = []
    
    // An array containing the fixed position and orientation for each duck.
    // These values are estimated from your screenshot.
    let duckPlacements: [DuckPlacement] = [
        // Top row
        .init(position: [-0.8, 1.7, -1.7], orientation: .init(angle: .pi / 5, axis: [1, 0, 1])),
        .init(position: [0.0, 2.0, -1.8], orientation: .init(angle: -.pi / 12, axis: [0, 1, 0])),
        .init(position: [0.7, 1.9, -1.8], orientation: .init(angle: .pi / 6, axis: [1, 0, -1])),
        // Middle row
        .init(position: [-1.0, 1.4, -1.7], orientation: .init(angle: .pi / 2.5, axis: [0, 1, 0])),
        .init(position: [1.2, 1.5, -2.0], orientation: .init(angle: -.pi / 2, axis: [0, 1, 0])),
        // Bottom row
        .init(position: [-0.8, 1.1, -1.6], orientation: .init(angle: .pi, axis: [0, 0, 1])),
        .init(position: [0.2, 0.8, -1.8], orientation: .init(angle: .pi / 2, axis: [0, 0, 1])),
        .init(position: [0.9, 1.0, -1.9], orientation: .init(angle: -.pi / 8, axis: [1, 0, 0]))
    ]

    var body: some View {
        RealityView(
            make: { content in
                // This runs once when the view is created.
            },
            update: { content in
                // This runs when @State changes to add the loaded ducks.
                for duck in duckEntities {
                    if duck.parent == nil {
                        content.add(duck)
                    }
                }
            }
        )
        .task {
            // This runs in the background to load the ducks.
            self.duckEntities = await loadDucks()
        }
    }
    
    /// Loads ducks based on the fixed placements array.
    func loadDucks() async -> [Entity] {
        var loadedDucks: [Entity] = []
        
        await withTaskGroup(of: Entity?.self) { group in
            // Loop through each fixed placement.
            for placement in duckPlacements {
                group.addTask {
                    return await createDuck(from: placement)
                }
            }
            
            // Collect the results as they finish loading.
            for await duck in group {
                if let duck {
                    loadedDucks.append(duck)
                }
            }
        }
        
        return loadedDucks
    }

    /// Creates a single duck entity from a specific placement data object.
    func createDuck(from placement: DuckPlacement) async -> Entity? {
        guard let duck = try? await Entity(named: "rubber_duck", in: realityKitContentBundle) else {
            return nil
        }
        
        // Set position and orientation from the placement data.
        duck.position = placement.position
        duck.orientation = placement.orientation
        
        duck.scale *= 0.05
        
        return duck
    }
}
