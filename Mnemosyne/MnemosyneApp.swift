// MnemosyneApp.swift

import SwiftUI

@main
struct MnemosyneApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // ✅ CHANGED: Remove the .task modifier that opened the space automatically.
            // The ContentView will now control when the space is opened and closed.
        }
        ImmersiveSpace(id: "MenuImmersiveSpace"){
            ImmersiveView()
        }
        ImmersiveSpace(id: "GameImmersiveSpace") {
            GameView() // Your interactive game view
        }
    }
}
