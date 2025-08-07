import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Use a loop to create and place 5 ducks in the scene
            for _ in 0..<5 {
                if let duck = await createFloatingDuck() {
                    content.add(duck)
                }
            }
        }
    }
    
    /// Creates a single duck entity with random positioning and animations.
    /// - Returns: An optional configured Entity.
    func createFloatingDuck() async -> Entity? {
        // Load the duck model
        guard let duck = try? await Entity(named: "rubber_duck", in: realityKitContentBundle) else {
            return nil
        }
        
        // 1. SCATTERING: Generate a random position for each duck
        // X: -2m to 2m (left/right)
        // Y: 1m to 2m (height)
        // Z: -1.5m to -3m (depth)
        let randomPosition = SIMD3<Float>(
            x: .random(in: -2...2),
            y: .random(in: 1...2),
            z: .random(in: -1.5...(-3))
        )
        duck.position = randomPosition
        duck.scale = [0.3, 0.3, 0.3] // Made the duck a bit bigger
        
        // 2. ANIMATIONS: Create both spinning and floating movements
        
        // --- Spinning Animation (Horizontal) ---
        // Give each duck a random spin duration to desynchronize them
        let spinDuration = Double.random(in: 10...20)
        let spinAnimation = FromToByAnimation<Transform>(
            name: "spin",
            from: .init(yaw: .pi),
            to: .init(yaw: -.pi),
            duration: spinDuration,
            timing: .linear,
        )

        // --- Floating Animation (Vertical) ---
        // Animate the duck's position up and down by 15cm
        var floatTransform = Transform(scale: duck.scale, rotation: duck.orientation, position: duck.position)
        floatTransform.translation.y += 0.15 // Move up by 15cm
        
        let floatDuration = Double.random(in: 2...4)
        let floatAnimation = FromToByAnimation<Transform>(
            name: "float",
            from: .init(scale: duck.scale, rotation: duck.orientation, position: duck.position),
            to: floatTransform,
            duration: floatDuration,
            timing: .easeInOut,
            autoreverses: true // This makes it go up and then back down smoothly
        )

        // 3. PLAY ANIMATIONS: Combine and play both animations on the duck
        if let spin = try? AnimationResource.generate(with: spinAnimation),
           let float = try? AnimationResource.generate(with: floatAnimation) {
            duck.playAnimation(spin)
            duck.playAnimation(float)
        }
        
        return duck
    }
}
