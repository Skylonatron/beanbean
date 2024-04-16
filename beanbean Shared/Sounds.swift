//
//  Sounds.swift
//  beanbean
//
//  Created by Sam Willenson on 4/16/24.
//

import AVFoundation

class Sounds {
    var popSoundPlayer: AVAudioPlayer?
    var redRockSoundPlayer: AVAudioPlayer?
    
    init() {
        preloadPopSound()
        preloadRedRockSound()
    }
    
    private func preloadPopSound() {
        DispatchQueue.global().async {
            if let popSoundURL = Bundle.main.url(forResource: "popSound", withExtension: "m4a") {
                do {
                    self.popSoundPlayer = try AVAudioPlayer(contentsOf: popSoundURL)
                    // Preload the sound by playing it with volume muted
                    self.popSoundPlayer?.volume = 0
                    self.popSoundPlayer?.play()
                    // Wait for a short duration to ensure the sound is loaded into memory
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Reset volume and stop playback
                        self.popSoundPlayer?.volume = 1
                        self.popSoundPlayer?.stop()
                    }
                } catch {
                    print("Error preloading pop sound: \(error.localizedDescription)")
                }
            } else {
                print("Pop sound file not found")
            }
        }
    }
    private func preloadRedRockSound() {
            DispatchQueue.global().async {
                if let redRockSoundURL = Bundle.main.url(forResource: "redRockSound", withExtension: "m4a") {
                    do {
                        self.redRockSoundPlayer = try AVAudioPlayer(contentsOf: redRockSoundURL)
                        self.redRockSoundPlayer?.volume = 0
                        self.redRockSoundPlayer?.play()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.redRockSoundPlayer?.volume = 1
                            self.redRockSoundPlayer?.stop()
                        }
                    } catch {
                        print("Error preloading red rock sound: \(error.localizedDescription)")
                    }
                } else {
                    print("Red rock sound file not found")
                }
            }
        }
    
    func playPopSound(chainCount: Int) {
        if let player = popSoundPlayer{
            player.stop()
            player.currentTime = 0
            let pitchAdjustment = Float(chainCount) * 0.8
//            print(pitchAdjustment)
            player.enableRate = true
            player.rate = 1.0 + pitchAdjustment
            player.play()
        }
        else{
            print("pop sound player not initialized")
        }
    }
    func playRedRockSound() {
        if let player = redRockSoundPlayer{
            player.stop()
            player.play()
        }

    }
}
