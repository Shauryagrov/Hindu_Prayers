// Create a dedicated AudioService class
import Foundation
import AVFoundation

protocol AudioServiceProtocol {
    func playAudio(fileName: String) throws
    func preloadAudio(fileNames: [String])
}

class AudioService: AudioServiceProtocol {
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    private var preloadedAudio = [String: AVAudioPlayer]()
    
    // Preload commonly used audio files
    func preloadAudio(fileNames: [String]) {
        Task.detached(priority: .background) {
            for fileName in fileNames {
                if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.prepareToPlay()
                        await MainActor.run {
                            self.preloadedAudio[fileName] = player
                        }
                    } catch {
                        print("Failed to preload audio: \(error)")
                    }
                }
            }
        }
    }
    
    // Use preloaded audio when available
    func playAudio(fileName: String) throws {
        if let player = preloadedAudio[fileName] {
            player.currentTime = 0
            player.play()
            return
        }
        
        // Fall back to loading on demand
        // Implementation details...
    }
} 