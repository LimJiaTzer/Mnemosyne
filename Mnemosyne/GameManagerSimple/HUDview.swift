import SwiftUI

struct HUDView: View {
    @Bindable var gameManager: GameManager

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(titleText)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.white)
            
            // ✅ CHANGED: This 'if' statement now checks for BOTH phases.
            if gameManager.phase == .memorizing || gameManager.phase == .identifying {
                // Display the countdown value.
                Text("Time: \(gameManager.countdownValue)")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .contentTransition(.numericText())
            }
            
            // Show the score only during the identifying phase.
            if gameManager.phase == .identifying {
                Text("Score: \(gameManager.score)")
                    .font(.title2)
            }
        }
        .padding(25)
        .frame(minWidth: 350)
        .glassBackgroundEffect()
        .animation(.default, value: gameManager.phase)
        .animation(.default, value: gameManager.score)
        .animation(.default, value: gameManager.countdownValue)
    }
    
    /// A computed property to determine the title text based on the game's current phase.
    private var titleText: String {
        // ✅ FIXED: The switch now includes ALL possible cases.
        switch gameManager.phase {
        case .settingUp:
            return "Setting Up..."
        case .memorizing:
            return "Memorize the Scene!" // This case was missing.
        case .transitioning:
            return "" // This case was missing. We want no text during the black screen.
        case .identifying:
            return "Find the Changes"
        case .finished:
            return "" // No title when the final score screen is up.
        }
    }
}
