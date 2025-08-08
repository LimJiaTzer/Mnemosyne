import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

// ✅ FIXED: Simplified GameState
enum GameState {
    case menu
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
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Group {
            // This switch controls the 2D window's content.
            switch gameState {
            case .menu:
                MainMenuView(gameState: $gameState, gameSettings: gameSettings)
            
            // ✅ FIXED: When the game is active, the 2D window should show the 'EndGameView'.
            // The immersive space will show the 'GameView' separately.
            case .game:
                EndGameView(gameState: $gameState)
            }
        }
        .task {
            // Open the decorative menu space on launch.
            await openImmersiveSpace(id: "MenuImmersiveSpace")
        }
        .onChange(of: gameState) {
            Task {
                // Always dismiss whatever is open first.
                await dismissImmersiveSpace()
                
                // Then open the correct space based on the new state.
                if gameState == .game {
                    await openImmersiveSpace(id: "GameImmersiveSpace")
                } else if gameState == .menu {
                    await openImmersiveSpace(id: "MenuImmersiveSpace")
                }
            }
        }
        .onAppear {
            // When the content view appears for the first time, start the music.
            AudioManager.shared.startBackgroundMusic()
        }
    }
}


// MARK: - Your UI Views

struct MainMenuView: View {
    @Binding var gameState: GameState
    var gameSettings: GameSettings
    @State private var showingRules: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        VStack(spacing: 50) {
            Text("🐣Mnemosyne").font(Font.custom("DynaPuff", size:100)).fontWeight(.heavy).foregroundColor(.white).shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
            VStack(spacing: 30) {
                Button {
                    // ✅ FIXED: Go directly to the game. No loading state needed.
                    gameState = .game
                } label: { Text("Start Game").font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60) }.buttonStyle(.borderedProminent).tint(Color(red: 34/255, green: 139/255, blue: 34/255))
                Button(action: { showingRules = true }) { Text("Rules").font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60) }.buttonStyle(.borderedProminent).tint(.brown)
                Button(action: { showingSettings = true }) { Text("Settings").font(.largeTitle).fontWeight(.semibold).frame(width: 320, height: 60) }.buttonStyle(.borderedProminent).tint(.gray)
            }.shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
        }.padding().sheet(isPresented: $showingRules) { RulesView(showingRules: $showingRules) }.sheet(isPresented: $showingSettings) { SettingsView(gameSettings: gameSettings, showingSettings: $showingSettings) }
    }
}
struct LoadingView: View {
    @Binding var gameState: GameState
    
    // ✅ FIXED: Use @State for classes marked with @Observable.
    // This correctly observes the shared instance for changes.
    @State private var arManager = ARManager.shared
    
    // ✅ REMOVED: This view no longer needs to dismiss the space directly.
    // @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Scanning Room").font(.largeTitle)
            
            // The view will now correctly update when arManager.hasFoundPlanes changes.
            if !arManager.hasFoundPlanes {
                ProgressView().progressViewStyle(.circular)
                Text("Move your device around to detect flat surfaces like floors and tables.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } else {
                Text("Planes Detected!").font(.headline).foregroundColor(.green)
                Text("Ready to start.")
            }
            
            Spacer()
            
            Button(action: {
                // The logic here is already correct.
                ARManager.shared.stop()
                gameState = .menu
            }) {
                Text("Cancel")
                    .font(.title3)
                    .padding(.horizontal, 40)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            Spacer().frame(height: 20)
        }
        .padding(40)
        .onChange(of: arManager.hasFoundPlanes) { _, hasFoundPlanes in
            if hasFoundPlanes {
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

// In ContentView.swift

struct EndGameView: View {
    @Binding var gameState: GameState
    
    // ✅ Access the single, shared instance of the GameManager.
    @State private var gameManager = GameManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // ✅ NEW: Add a Text view to display the countdown timer.
            // This will automatically update.
            Text("Time Remaining: \(gameManager.countdownValue)")
                .font(.title2)
                .fontWeight(.semibold)

            Button("End Game") {
                gameState = .menu
                // We should also cancel the game task when the user manually ends it.
                gameManager.resetGame() // Assuming resetGame cancels the task.
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(30)
        .glassBackgroundEffect()
    }
}
