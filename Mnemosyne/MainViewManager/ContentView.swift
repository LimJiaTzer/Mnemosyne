import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

// App-wide State Management
enum GameState {
    case menu
    case loading
    case game
}

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

@Observable
class GameSettings {
    var difficulty: Difficulty = .easy
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var gameState: GameState = .menu
    @State private var gameSettings = GameSettings()

    var body: some View {
        switch gameState {
        case .menu:
            MainMenuView(
                gameState: $gameState,
                gameSettings: gameSettings
            )
        case .loading:
            LoadingView(gameState: $gameState)
        case .game:
            GameView(gameState: $gameState)
                // Inject the settings into the environment for GameView.
                .environment(gameSettings)
        }
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    @Binding var gameState: GameState
    var gameSettings: GameSettings
    
    @State private var showingRules: Bool = false
    @State private var showingSettings: Bool = false
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 50) {
            Text("🐣Mnemosyne")
                .font(Font.custom("DynaPuff", size:100))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
            
            VStack(spacing: 30) {
                Button {
                    Task { await dismissImmersiveSpace() }
                    gameState = .loading
                    ARManager.shared.start()
                } label: {
                    Text("Start Game")
                        .font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent).tint(Color(red: 34/255, green: 139/255, blue: 34/255))
                
                Button(action: { showingRules = true }) {
                    Text("Rules")
                        .font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent).tint(.brown)
                
                Button(action: { showingSettings = true }) {
                    Text("Settings")
                        .font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60)
                }
                .buttonStyle(.borderedProminent).tint(.gray)
            }
            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
        }
        .padding()
        .sheet(isPresented: $showingRules) { RulesView(showingRules: $showingRules) }
        .sheet(isPresented: $showingSettings) { SettingsView(gameSettings: gameSettings, showingSettings: $showingSettings) }
    }
}

// In ContentView.swift

// MARK: - Loading View
struct LoadingView: View {
    @Binding var gameState: GameState
    @StateObject private var arManager = ARManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Scanning Room")
                .font(.largeTitle)
            
            if !arManager.hasFoundPlanes {
                ProgressView().progressViewStyle(.circular)
                Text("Move your device around to detect flat surfaces like floors and tables.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } else {
                Text("Planes Detected!")
                    .font(.headline)
                    .foregroundColor(.green)
                Text("Ready to start.")
            }
            
            Spacer() // Pushes the button down
            
            // ✅ New Cancel Button
            Button(action: {
                // Stop the AR session to save battery.
                arManager.stop()
                // Go back to the main menu.
                gameState = .menu
            }) {
                Text("Cancel")
                    .font(.title3)
                    .padding(.horizontal, 40)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(40)
        .onChange(of: arManager.hasFoundPlanes) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    gameState = .game
                }
            }
        }
    }
}

// RulesView and SettingsView remain the same
struct RulesView: View {
    @Binding var showingRules: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Rules & Tips").font(.largeTitle).bold()
                Spacer()
                Button("Done") { showingRules = false }.buttonStyle(.plain).font(.title2)
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
        }.padding(40)
    }
}

struct SettingsView: View {
    var gameSettings: GameSettings
    @Binding var showingSettings: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Settings").font(.largeTitle).bold()
                Spacer()
                Button("Done") { showingSettings = false }.buttonStyle(.plain).font(.title2)
            }
            VStack(alignment: .leading, spacing: 15) {
                Text("Difficulty Level").font(.title).fontWeight(.bold)
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Button(action: { gameSettings.difficulty = difficulty }) {
                        HStack {
                            Text(difficulty.rawValue)
                            Spacer()
                            if gameSettings.difficulty == difficulty {
                                Image(systemName: "checkmark")
                            }
                        }
                        .font(.title2).padding().background(difficulty.color.opacity(0.2)).foregroundColor(.primary).cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }.padding(40)
    }
}

