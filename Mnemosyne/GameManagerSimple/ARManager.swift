// ARManager.swift (Corrected)

import SwiftUI
import ARKit

@Observable
class ARManager {
    static let shared = ARManager()

    private var session = ARKitSession()
    private var planeDataProvider = PlaneDetectionProvider(alignments: [.horizontal])
    
    // This property is watched by the LoadingView.
    var hasFoundPlanes = false
    
    // This property is used by the GameImmersiveView.
    var detectedPlanes: [PlaneAnchor] = []
    
    // ✅ FIXED: Add our own state-tracking variable.
    private var isRunning = false

    private init() { }

    func start() {
        // ✅ FIXED: Check our local 'isRunning' flag instead of the non-existent 'session.state'.
        guard !isRunning else { return }
        
        // Set our flag to true immediately.
        self.isRunning = true
        
        // Reset state for the new session.
        self.hasFoundPlanes = false
        self.detectedPlanes = []
        
        Task {
            do {
                try await session.run([planeDataProvider])
                
                for await update in planeDataProvider.anchorUpdates {
                    if update.event == .added {
                        let planeAnchor = update.anchor
                        self.detectedPlanes.append(planeAnchor)
                        
                        if !self.hasFoundPlanes {
                            self.hasFoundPlanes = true
                        }
                    }
                }
            } catch {
                print("Failed to start ARKit session: \(error)")
                // If starting fails, reset our flag.
                self.isRunning = false
            }
        }
    }

    func stop() {
        session.stop()
        // ✅ FIXED: Reset our flag when the session is stopped.
        self.isRunning = false
    }
}
