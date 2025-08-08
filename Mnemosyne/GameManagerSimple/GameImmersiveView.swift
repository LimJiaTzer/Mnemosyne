// GameImmersiveView.swift (Corrected and Simplified)

import SwiftUI
import RealityKit

struct GameImmersiveView: View {
    // We only need the GameManager now.
    @State private var gameManager = GameManager.shared

    var body: some View {
        RealityView { content, attachments in
            // Add the root entity from our game manager.
            content.add(gameManager.rootEntity)
            
            // Position the timer view overlay.
            if let timerAttachment = attachments.entity(for: "timer_view") {
                timerAttachment.position = [0.65, 0.35, -1]
                content.add(timerAttachment)
            }
        }
        attachments: {
            Attachment(id: "timer_view") {
                HUDView(gameManager: gameManager)
            }
        }
        // ✅ CORRECTED: The only task needed is to start the game directly.
        // There is no more plane detection.
        .task {
            gameManager.startGame()
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
