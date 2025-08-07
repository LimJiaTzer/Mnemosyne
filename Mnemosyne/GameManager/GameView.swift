import SwiftUI
import RealityKit
import RealityKitContent

struct GameView: View {
    @Binding var gameState: GameState
    
    // Get the shared game settings from the environment.
    @Environment(GameSettings.self) var gameSettings
    
    // Get the shared instance of the ARManager.
    @StateObject private var arManager = ARManager.shared

    var body: some View {
        ZStack(alignment: .top) {
            RealityView { content in
                // Add the manager's root entity to the scene.
                // This entity will contain both the plane visualizations
                // and the duck anchors once they are loaded.
                content.add(arManager.rootEntity)
            }
            
            // Your UI sits on top of the RealityView.
            VStack(spacing: 30) {
                Text("Ducks have been placed! Find the differences.")
                    .font(.headline)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(15)
                
                Spacer() // Pushes the button to the bottom
                
                Button(action: {
                    // Stop the AR session when returning to the menu.
                    arManager.stop()
                    gameState = .menu
                }) {
                    Text("Back to Menu")
                        .font(.title2)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 34/255, green: 139/255, blue: 34/255))
            }
            .padding(30)
        }
        .task {
            // This asynchronous task runs once when the GameView appears.
            
            // 1. Call the helper function to create all the duck anchors.
            //    It passes the selected difficulty and the planes found by the ARManager.
            let duckAnchors = await DuckHelpers.populateDucks(
                difficulty: gameSettings.difficulty,
                planeAnchors: arManager.planeAnchors,
                from: realityKitContentBundle
            )
            
            // 2. Once the ducks are created, add them all to the scene.
            for anchor in duckAnchors {
                arManager.rootEntity.addChild(anchor)
            }
        }
    }
}

