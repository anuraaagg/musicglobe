//
//  AudioPlayerService.swift
//  musicglobe
//
//  Handles preview playback using AVFoundation
//

import AVFoundation
import Combine
import SwiftUI

class AudioPlayerService: ObservableObject {
    var player: AVPlayer?
    @Published var isPlaying = false
    
    // Play a remote URL
    func play(url: URL) {
        // Stop current
        pause()
        
        // Setup simple player
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Play
        player?.play()
        isPlaying = true
        
        // Observer for end
        NotificationCenter.default.addObserver(self, selector: #selector(didFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    // Toggle play/pause for same URL
    func toggle() {
        if isPlaying {
            pause()
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    @objc func didFinish() {
        isPlaying = false
        // Optionally reset to start?
        // player?.seek(to: .zero)
    }
}
