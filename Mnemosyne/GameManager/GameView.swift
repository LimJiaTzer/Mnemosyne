// GameView.swift (Corrected with .onAppear)

import SwiftUI
import RealityKit

struct GameView: View {
    @State private var gameManager = GameManager.shared

    var body: some View {
        ZStack {
            RealityView { content, attachments in
                content.add(gameManager.rootEntity)
                if let hudAttachment = attachments.entity(for: "hud_view") {
                    hudAttachment.position = [0, 0.6, -1.5]
                    content.add(hudAttachment)
                }
            }
            attachments: {
                Attachment(id: "hud_view") {
                    HUDView(gameManager: gameManager)
                }
            }
            
            if gameManager.phase == .transitioning {
                Rectangle().fill(.black).ignoresSafeArea()
            }
            
            if gameManager.phase == .finished {
                VStack(spacing: 20) {
                    Text("Round Over!").font(.largeTitle)
                    Text("Final Score: \(gameManager.score)").font(.title)
                    Text("Correct: \(gameManager.correctSelections) | Incorrect: \(gameManager.incorrectSelections)").font(.headline)
                    Button("Play Again") {
                        gameManager.startGame()
                    }
                    .padding()
                }
                .padding(40)
                .glassBackgroundEffect()
            }
        }
        // ✅ THIS IS THE FIX ✅
        // Replace '.task' with '.onAppear' to ensure the game resets every time.
        .onAppear {
            // We still need a Task here because onAppear is not an async context.
            Task {
                gameManager.startGame()
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    gameManager.duckTapped(entity: value.entity)
                }
        )
    }
}
