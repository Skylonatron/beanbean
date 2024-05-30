//
//  Music.swift
//  beanbean
//
//  Created by Skylar Jones on 5/15/24.
//

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer?

func playBackgroundMusic(muteMusic: Bool) {
    
    if !muteMusic {
        if let musicURL = Bundle.main.url(forResource: "orbDorbTest", withExtension: "flac") {
            do {
                try backgroundMusicPlayer = AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = 0.5 // Set initial volume level
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not play background music: \(error)")
            }
        } else {
            print("Background music file not found")
        }
        
    }
}

func stopBackgroundMusic(muteMusic: Bool) {
    if muteMusic {
        backgroundMusicPlayer?.stop()
    }
}


