//// TimerView.swift (Corrected)
//
//import SwiftUI // ✅ FIXED: Add this import statement.
//
//struct TimerView: View {
//    @Bindable var gameManager: GameManager
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            // This view now only displays the title text.
//            Text(titleText)
//                .font(.title)
//                .fontWeight(.heavy)
//                .foregroundColor(.white)
//        }
//        .padding(25)
//        .frame(minWidth: 280)
//        .glassBackgroundEffect()
//        .animation(.default, value: gameManager.phase)
//    }
//    
//    /// A computed property to determine the title text based on the game's current phase.
//    private var titleText: String {
//        switch gameManager.phase {
//        case .settingUp:
//            return "Placing Ducks..."
//        case .identifying:
//            return "Find the Changes"
//        case .finished:
//            return "Game Over"
//
//        }
//    }
//}
