import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

// MARK: - App-wide State Management

// Enum to manage the different states of the application
enum GameState {
    case menu
    case game
}

// Enum to define the difficulty levels, now with associated colors
enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    // Computed property to return a color for each difficulty
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

// An observable object to hold shared settings that can be accessed by any view
@Observable
class GameSettings {
    var difficulty: Difficulty = .easy
}

// MARK: - Main Content View
struct ContentView: View {
    // State variable to control the current view being displayed
    @State private var gameState: GameState = .menu
    // State object to hold the game's settings
    @State private var gameSettings = GameSettings()

    var body: some View {
        // Use a switch statement to display the appropriate view based on the game state
        switch gameState {
        case .menu:
            // Pass the state bindings and environment object to the main menu view
            MainMenuView(
                gameState: $gameState,
                gameSettings: gameSettings
            )
        case .game:
            GameView(gameState: $gameState) // Pass binding to allow returning to menu
        }
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    @Binding var gameState: GameState
    var gameSettings: GameSettings
    
    @State private var showingRules: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        
        VStack(spacing: 50) {
            Text("🐣Mnemosyne")
                .font(Font.custom("DynaPuff", size:100))
                .fontWeight(.heavy)
                .foregroundColor(.white)
            // Added a shadow for better readability against the 3D model
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
            
            VStack(spacing: 30) {
                Button(action: { gameState = .game }) {
                    Text("Start Game")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 34/255, green: 139/255, blue: 34/255))
                Button(action: { showingRules = true }) {
                    Text("Rules")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                
                Button(action: { showingSettings = true }) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
            }
            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
        }
        .padding()
        .sheet(isPresented: $showingRules) {
            RulesView(showingRules: $showingRules)
                .sheet(isPresented: $showingSettings) {
                    SettingsView(gameSettings: gameSettings, showingSettings: $showingSettings)
                }
        }
    }
}

// MARK: - Placeholder Game View
struct GameView: View {
    @Binding var gameState: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to the Game!")
                .font(.largeTitle)
                .padding()
            Text("This is where your game content would go.")
                .font(.title3)
            Button(action: { gameState = .menu }) {
                Text("Back to Menu")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}
    
// MARK: - Rules View
struct RulesView: View {
    @Binding var showingRules: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Rules & Tips")
                    .font(.largeTitle).bold()
                Spacer()
                Button("Done") { showingRules = false }
                    .buttonStyle(.plain).font(.title2)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Rules:").font(.title).fontWeight(.bold)
                Text("1. You will be entering a room with several ducks.").font(.title3)
                Text("2. Remember the position and orientation of them.").font(.title3)
                Text("3. Identify ducks missing or of incorrect orientation.").font(.title3)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Tips:").font(.title).fontWeight(.bold)
                Text("1. Use your surroundings to orient yourself.").font(.title3)
                Text("2. Try to remember the ducks' positions relative to objects.").font(.title3)
            }
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    // The settings object is passed in to be modified.
    var gameSettings: GameSettings
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Settings")
                    .font(.largeTitle).bold()
                Spacer()
                Button("Done") { showingSettings = false }
                    .buttonStyle(.plain).font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Difficulty Level")
                    .font(.title).fontWeight(.bold)
                
                // Buttons to change the difficulty in the shared settings object
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Button(action: {
                        gameSettings.difficulty = difficulty
                    }) {
                        HStack {
                            Text(difficulty.rawValue)
                            Spacer()
                            // Show a checkmark next to the selected difficulty
                            if gameSettings.difficulty == difficulty {
                                Image(systemName: "checkmark")
                            }
                        }
                        .font(.title2)
                        .padding()
                        .background(difficulty.color.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
}


// MARK: - Preview
#Preview(windowStyle: .automatic) {
    ContentView()
}

