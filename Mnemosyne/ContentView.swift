import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    // State to track the currently selected difficulty
    @State private var selectedDifficulty: Difficulty = .easy

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

    var body: some View {
        // Main container to fill the space
        VStack(spacing: 0) {
            
            // --- Top Title Section ---
            HStack(spacing: 15) {
                Model3D(named: "Scene", bundle: realityKitContentBundle) { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }

                Text("Mnemosyne")
                    .font(.system(size: 48, weight: .bold))
                
                Spacer() // Pushes the title to the left
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            
            // --- Main Content Area (Two Columns) ---
            HStack(alignment: .top, spacing: 40) {
                
                // --- Left Column (Rules and Tips) ---
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rules:")
                            .font(.title2)
                            .fontWeight(.bold)
                        // Increased font size for rules
                        Text("1. You will be entering a room with several ducks.")
                            .font(.system(size: 20))
                        Text("2. Remember the position and orientation of them.")
                            .font(.system(size: 20))
                        Text("3. Identify ducks missing or of incorrect orientation.")
                            .font(.system(size: 20))
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips:")
                            .font(.title2)
                            .fontWeight(.bold)
                        // Increased font size for tips
                        Text("1. Use your surroundings to orient yourself.")
                            .font(.system(size: 20))
                        Text("2. Try to remember the ducks' positions relative to objects.")
                            .font(.system(size: 20))
                    }
                }
                .padding(30)
                .background(.regularMaterial, in: .rect(cornerRadius: 20))
                .frame(maxWidth: 500) // Constrain the width of the left column
                
                // --- Right Column (Difficulty) ---
                VStack(alignment: .leading, spacing: 20) {
                    Text("Difficulty Level")
                        .font(.title)
                        .fontWeight(.bold)

                    // Difficulty Buttons
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button(action: {
                            selectedDifficulty = difficulty
                        }) {
                            Text(difficulty.rawValue)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selectedDifficulty == difficulty ? difficulty.color : .gray.opacity(0.5))
                    }
                }
                .frame(width: 250) // Constrain the width of the right column

            } // End of main HStack
            .padding(40)
            
            Spacer() // Pushes the main content to the top of the screen
            
            // --- Bottom Play Button ---
            Button(action: {
                // Add action to start the game here
                print("Starting game with difficulty: \(selectedDifficulty.rawValue)")
            }) {
                Text("Play")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(selectedDifficulty.color)
            .padding(40)
            
        } // End of main VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview(windowStyle: .automatic) {
    ContentView()
}


