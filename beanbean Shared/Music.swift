//
//  Music.swift
//  beanbean
//
//  Created by Skylar Jones on 5/15/24.
//

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer?

func playBackgroundMusic(muteMusic: Bool) {
    if backgroundMusicPlayer?.isPlaying == true || backgroundMusicPlayer?.isPlaying == false {
        return // Don't restart if already exists
    }
    if let musicURL = Bundle.main.url(forResource: "orbDorbTest", withExtension: "flac") {
        do {
            try backgroundMusicPlayer = AVAudioPlayer(contentsOf: musicURL)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.5 // Set initial volume level
            backgroundMusicPlayer?.play()
            if muteMusic {
                backgroundMusicPlayer?.volume = 0.0
            }
        } catch {
            print("Could not play background music: \(error)")
        }
    } else {
        print("Background music file not found")
    }
        
    
}

func handleMusicVolume(muteMusic: Bool) {
    if muteMusic {
        backgroundMusicPlayer?.volume = 0.4
        backgroundMusicPlayer?.stop()
    }
    if !muteMusic && (backgroundMusicPlayer?.volume == 0.4 || backgroundMusicPlayer?.volume == 0) {
        backgroundMusicPlayer?.volume = 0.5
        backgroundMusicPlayer?.play()
    }
}





