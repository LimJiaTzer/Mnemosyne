// AudioManager.swift

import Foundation
import AVFoundation // The framework for all audio-related tasks.

class AudioManager {
    // Create a single, shared instance of the audio manager.
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?

    // The private initializer ensures no other part of the app can create a second instance.
    private init() { }

    func startBackgroundMusic() {
        // Find the music file in your app's bundle.
        // Make sure the "forResource" name and "withExtension" match your file EXACTLY.
        guard let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Error: Could not find the music file 'background_music.mp3'")
            return
        }
        
        do {
            // Initialize the audio player with the URL of your music file.
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            
            // Configure the player.
            audioPlayer?.numberOfLoops = -1 // -1 means loop forever.
            audioPlayer?.volume = 0.3      // Set a reasonable volume (0.0 to 1.0).
            
            // Prepare the audio to play. This preloads the audio buffer for smooth playback.
            audioPlayer?.prepareToPlay()
            
            // Start playing!
            audioPlayer?.play()
            print("Background music started.")
            
        } catch {
            // If the player fails to initialize, print the error.
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
        print("Background music stopped.")
    }
}
