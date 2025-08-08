// GameManager.swift

import SwiftUI
import RealityKit
import RealityKitContent

@Observable
class GameManager {
    // SINGLETON PATTERN: Creates a single, shared instance that all views can access.
    static let shared = GameManager()
    
    // REUSABLE TIMER: This property is used for both the memorizing and identifying countdowns.
    var countdownValue: Int = 0
    
    // --- Game State & Data Properties ---
    enum GamePhase { case settingUp, memorizing, transitioning, identifying, finished }
    enum DuckStatus { case originalCorrect, originalIncorrect, newlyAdded }
    struct GameDuck {
        let id = UUID()
        var entity: Entity
        var status: DuckStatus
    }
    
    var phase: GamePhase = .settingUp
    var ducks: [GameDuck] = []
    let rootEntity = Entity()
    var score: Int = 0
    var correctSelections: Int = 0
    var incorrectSelections: Int = 0
    private var totalTargets: Int = 0
    private var gameTask: Task<Void, Error>?

    // Private initializer to enforce the singleton pattern.
    private init() { }

    // MARK: - Game Flow

    @MainActor
    func startGame() {
        gameTask?.cancel()
        gameTask = Task {
            // --- Memorizing Phase ---
            self.phase = .settingUp
            await resetAndSetupScene()
            self.phase = .memorizing
            
            // Start a 10-second countdown for the user to memorize the scene.
            await runCountdown(seconds: 10)
            try Task.checkCancellation()
            
            // --- Transition Phase ---
            self.phase = .transitioning
            self.rootEntity.isEnabled = false // Hide ducks
            try await Task.sleep(for: .seconds(2))
            try Task.checkCancellation()

            // --- Identifying Phase ---
            await createPuzzleState()
            self.rootEntity.isEnabled = true // Show ducks again
            self.phase = .identifying
            
            // Start a 60-second countdown for the user to find the changes.
            await runCountdown(seconds: 60)
            
            // If the timer runs out and the user hasn't found all targets, end the game.
            if self.phase == .identifying {
                self.phase = .finished
            }
        }
    }
    
    /// A reusable countdown timer that updates the `countdownValue` property.
    @MainActor
    private func runCountdown(seconds: Int) async {
        self.countdownValue = seconds
        
        while self.countdownValue > 0 {
            // This loop exits if the task is cancelled or the phase changes.
            guard self.phase == .memorizing || self.phase == .identifying else { break }
            
            do {
                try await Task.sleep(for: .seconds(1))
                try Task.checkCancellation()
                self.countdownValue -= 1
            } catch {
                // The task was cancelled, so we stop the timer.
                return
            }
        }
    }
    
    @MainActor
    private func resetAndSetupScene() async {
        ducks.removeAll()
        rootEntity.children.removeAll()
        score = 0
        correctSelections = 0
        incorrectSelections = 0
        totalTargets = 0
        await generateInitialDucks(count: 3)
    }

    @MainActor
    private func generateInitialDucks(count: Int) async {
        for _ in 0..<count {
            if let duckEntity = await createDuckEntity() {
                let (randomPosition, randomOrientation) = getRandomTransform()
                duckEntity.position = randomPosition
                duckEntity.orientation = randomOrientation
                let gameDuck = GameDuck(entity: duckEntity, status: .originalCorrect)
                self.ducks.append(gameDuck)
                await self.rootEntity.addChild(duckEntity)
            }
        }
    }

    @MainActor
    private func createPuzzleState() async {
        // Rotate one duck
        if let indexToAlter = self.ducks.indices.randomElement() {
            let randomRotation = simd_quatf(angle: .pi * Float.random(in: 0.2...0.8), axis: .randomNormalized)
            self.ducks[indexToAlter].entity.orientation *= randomRotation
            self.ducks[indexToAlter].status = .originalIncorrect
            self.totalTargets += 1
        }
        
        // Add new ducks
        for _ in 0..<2 {
            if let newDuckEntity = await createDuckEntity() {
                let (randomPosition, randomOrientation) = getRandomTransform()
                newDuckEntity.position = randomPosition
                newDuckEntity.orientation = randomOrientation
                let newGameDuck = GameDuck(entity: newDuckEntity, status: .newlyAdded)
                self.ducks.append(newGameDuck)
                await self.rootEntity.addChild(newDuckEntity)
                self.totalTargets += 1
            }
        }
    }

    @MainActor
    func duckTapped(entity: Entity) {
        // Ignore taps if we aren't in the identifying phase.
        guard self.phase == .identifying else { return }

        // Find the duck data that corresponds to the tapped 3D entity.
        guard let tappedDuckIndex = self.ducks.firstIndex(where: { $0.entity == entity }) else {
            return
        }
        
        let tappedDuck = self.ducks[tappedDuckIndex]
        var highlightColor: SimpleMaterial.Color

        if tappedDuck.status == .newlyAdded || tappedDuck.status == .originalIncorrect {
            highlightColor = .green
            self.score += 10
            self.correctSelections += 1
        } else {
            highlightColor = .red
            self.score -= 5
            self.incorrectSelections += 1
        }
        
        // This modification is now guaranteed to be safe.
        if var modelComponent = tappedDuck.entity.components[ModelComponent.self] {
            let material = SimpleMaterial(color: highlightColor, isMetallic: false)
            modelComponent.materials = [material]
            self.ducks[tappedDuckIndex].entity.components.set(modelComponent)
        }
        
        // This is also safe.
        self.ducks[tappedDuckIndex].entity.components.remove(InputTargetComponent.self)
        
        if self.correctSelections == self.totalTargets {
            self.phase = .finished
        }
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func createDuckEntity() async -> Entity? {
        guard let duck = try? await Entity(named: "rubber_duck", in: realityKitContentBundle) else { return nil }
        
        duck.scale *= 0.05
        await duck.components.set(InputTargetComponent())
        await duck.components.set(HoverEffectComponent())
        
        let shape = ShapeResource.generateBox(size: [0.5, 0.5, 0.5]).offsetBy(translation: [0, 0.25, 0])
        await duck.components.set(CollisionComponent(shapes: [shape]))
        
        return duck
    }
    
    private func getRandomTransform() -> (position: SIMD3<Float>, orientation: simd_quatf) {
        let randomX = Float.random(in: -1...1)
        let randomY = Float.random(in: 1...2)
        let randomZ = Float(-2.5)
        let position = SIMD3<Float>(randomX, randomY, randomZ)
        let randomAngle = Float.random(in: 0..<(2 * .pi))
        let orientation = simd_quatf(angle: randomAngle, axis: .randomNormalized)
        return (position: position, orientation: orientation)
    }

    func resetGame() {
        gameTask?.cancel()
        phase = .settingUp
    }
}

fileprivate extension SIMD3 where Scalar == Float {
    static var randomNormalized: SIMD3<Float> {
        return simd_normalize(SIMD3<Float>(x: .random(in: -1...1), y: .random(in: -1...1), z: .random(in: -1...1)))
    }
}
