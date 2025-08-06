import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

// Enum to manage the different states of the application
enum GameState {
    case menu
    case game
}

struct ContentView: View {
    // State variable to control the current view being displayed
    @State private var gameState: GameState = .menu
    // State variable to control the presentation of the rules sheet
    @State private var showingRules: Bool = false

    var body: some View {
        // Use a switch statement to display the appropriate view based on the game state
        switch gameState {
        case .menu:
            // Pass the state bindings to the main menu view
            MainMenuView(
                gameState: $gameState,
                showingRules: $showingRules
            )
        case .game:
            GameView(gameState: $gameState) // Pass binding to allow returning to menu
        }
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    @Binding var gameState: GameState
    @Binding var showingRules: Bool

    var body: some View {
        VStack(spacing: 40) {
            Text("🧠 Mnemosyne")
                .font(.system(size: 52, weight: .bold))


            VStack(spacing: 20) {
                // BUG FIX: Use .buttonStyle and .tint for modern, filled buttons
                Button(action: { gameState = .game }) {
                    Text("Start Game")
                        .font(.title2)
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button(action: { showingRules = true }) {
                    Text("Rules")
                        .font(.title2)
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)

                Button(action: quitGame) {
                    Text("Quit")
                        .font(.title2)
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        // Present the RulesView as a sheet when showingRules is true
        .sheet(isPresented: $showingRules) {
            RulesView(showingRules: $showingRules)
        }
    }
    
    private func quitGame() {
        print("Quit tapped - User should close the app from the system.")
    }
}

// MARK: - Placeholder Game View
struct GameView: View {
    // Binding to allow the GameView to change the gameState (e.g., back to menu)
    @Binding var gameState: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to the Game!")
                .font(.largeTitle)
                .padding()

            Text("This is where your game content would go.")
                .font(.title3)

            Button(action: {
                // Navigate back to the main menu
                gameState = .menu
            }) {
                Text("Back to Menu")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}
    
// MARK: - Rules View
// This view displays the game rules and tips.
struct RulesView: View {
    // Binding to dismiss the sheet
    @Binding var showingRules: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Header with title and Done button
            HStack {
                Text("Rules & Tips")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button("Done") {
                    showingRules = false
                }
                .buttonStyle(.plain) // Use plain style for text-like buttons in sheets
                .font(.title2)
            }

            // Rules Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Rules:")
                    .font(.title)
                    .fontWeight(.bold)
                Text("1. You will be entering a room with several ducks.")
                    .font(.title3)
                Text("2. Remember the position and orientation of them.")
                    .font(.title3)
                Text("3. Identify ducks missing or of incorrect orientation.")
                    .font(.title3)
            }
            
            // Tips Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Tips:")
                    .font(.title)
                    .fontWeight(.bold)
                Text("1. Use your surroundings to orient yourself.")
                    .font(.title3)
                Text("2. Try to remember the ducks' positions relative to objects.")
                    .font(.title3)
            }
            
            Spacer() // Pushes content to the top
        }
        .padding(40)
    }
}

// Corrected Preview
#Preview (windowStyle: .automatic){
    ContentView()
}

