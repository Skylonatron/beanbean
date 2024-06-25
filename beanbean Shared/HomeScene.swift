//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit
import AVFoundation

class HomeScene: SKScene {
    
    var game: Game!
    var settingsMenu: SKNode!
    var muteSounds: Bool = false
    var muteMusic: Bool = true
        
    class func newHomeScene() -> HomeScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = HomeScene()
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        let outline = outline(
            width: self.size.width / 2,
            height: self.size.height / 2,
            lineWidth: 8
        )
        self.addChild(outline)

        let soloButton = addButton(outlineFrame: outline.frame, name: "Solo")
        soloButton.position = CGPoint(x: 0, y: frame.width / 10)
        outline.addChild(soloButton)
        
        let multiButton = addButton(outlineFrame: outline.frame, name: "Multi")
        multiButton.position = CGPoint(x: 0, y: 0)
        outline.addChild(multiButton)
        
        let matchmakingButton = addButton(outlineFrame: outline.frame, name: "Online")
        matchmakingButton.position = CGPoint(x: 0, y: -frame.width / 10)
        outline.addChild(matchmakingButton)
        
        let settingsIconTexture = SKTexture(imageNamed: "settings_icon")
        let settingsButton = SKSpriteNode(texture: settingsIconTexture)
        settingsButton.position = CGPoint(x: frame.width / 7, y: frame.height / 5)
        settingsButton.name = "settingsButton"
        outline.addChild(settingsButton)
    }
    
    func addButton(outlineFrame: CGRect, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(
            width: frame.width / 10,
            height: frame.height / 10
        ))
        button.position = CGPoint(x: 0, y: 0)
        button.fillColor = SKColor.white
        button.strokeColor = SKColor.black
        button.lineWidth = 8
        button.name = name
        
        let labelNode = SKLabelNode()
        labelNode.text = name
        labelNode.name = name
        labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        labelNode.fontColor = .black
        labelNode.fontSize = 40
        labelNode.fontName = "ChalkboardSE-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        button.addChild(labelNode) // Add label as child of shape node
        return button  
    }
    

    
    
    override func didMove(to view: SKView) {
//        self.size = view.bounds.size
        self.size = CGSize(width: 1366.0, height: 1024.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setUpScene()
        self.muteMusic = !(backgroundMusicPlayer?.isPlaying ?? false)
        playBackgroundMusic(muteMusic: self.muteMusic)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    func showSettingsMenu() {
        settingsMenu = SKNode()
        settingsMenu.zPosition = 21
        

        let background = SKSpriteNode(
            color: .white,
            size: CGSize(width: self.view!.bounds.width / 1.3, height: self.view!.bounds.height / 2.5)
        )
//        background.alpha = 0.90
        background.position = CGPoint(x: 0, y: 0)
        settingsMenu.addChild(background)
        
        self.muteMusic = !(backgroundMusicPlayer?.isPlaying ?? false)
        
        let yOffset = background.size.height / 4

        let backButton = SKLabelNode(text: "Back")
        backButton.position = CGPoint(x: 0, y: background.size.height / 3 - 3 * yOffset)
        backButton.name = "settingsBack"
        backButton.fontColor = .black
        settingsMenu.addChild(backButton)
        
        let soundsLabel = SKLabelNode(text: "Sounds")
        soundsLabel.position = CGPoint(x: background.size.width / 4, y: background.size.height/3 - yOffset / 2)
        soundsLabel.fontColor = .black
        settingsMenu.addChild(soundsLabel)
        
        let musicLabel = SKLabelNode(text: "Music")
        musicLabel.position = CGPoint(x: -background.size.width / 4, y: background.size.height/3 - yOffset / 2)
        musicLabel.fontColor = .black
        settingsMenu.addChild(musicLabel)
        
        let musicIconTexture = SKTexture(imageNamed: muteMusic ? "music_off" : "music_on")
        let muteMusicCheckbox = SKSpriteNode(texture: musicIconTexture)
        muteMusicCheckbox.position = CGPoint(x: -background.size.width / 4, y: background.size.height / 3 - yOffset)
        muteMusicCheckbox.name = "muteMusicCheckbox"
        settingsMenu.addChild(muteMusicCheckbox)
        
        let soundsIconTexture = SKTexture(imageNamed: muteSounds ? "sounds_off" : "sounds_on")
        let muteSoundsCheckbox = SKSpriteNode(texture: soundsIconTexture)
        muteSoundsCheckbox.position = CGPoint(x: background.size.width / 4, y: background.size.height / 3 - yOffset)
        muteSoundsCheckbox.name = "muteSoundsCheckbox"
        settingsMenu.addChild(muteSoundsCheckbox)
        
        self.addChild(settingsMenu)
    }
    func updateMuteCheckbox() {
        if let muteMusicCheckbox = settingsMenu.childNode(withName: "muteMusicCheckbox") as? SKSpriteNode {
            let newTexture = SKTexture(imageNamed: muteMusic ? "music_off" : "music_on")
            muteMusicCheckbox.texture = newTexture
        }
        if let muteSoundsCheckbox = settingsMenu.childNode(withName: "muteSoundsCheckbox") as? SKSpriteNode {
            let newTexture = SKTexture(imageNamed: muteSounds ? "sounds_off" : "sounds_on")
            muteSoundsCheckbox.texture = newTexture
        }
        
    }
    
   
    

}

#if os(OSX)
// Mouse-based event handling
extension HomeScene {
    
    override func mouseDown(with event: NSEvent) {
        // for debugging you can click on a cell and see if there is a bean there
        let location = event.location(in: self)
        let node = self.atPoint(location)
        if node.name == "Solo" {
            let gameScene = GameScene.newGameScene(mode: .single)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            
        }
        if node.name == "Multi" {
            let gameScene = GameScene.newGameScene(mode: .localMultiplayer)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            
        }
    }
}
#endif

#if os(iOS) || os(tvOS)

extension HomeScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        // Check if touch intersects with the node's frame
        if node.name == "Solo" {
            let gameScene = GameScene.newGameScene(mode: .single)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
        if node.name == "Multi" {
            let gameScene = GameScene.newGameScene(mode: .localMultiplayer)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
        if node.name == "Online" {
            let matchmakingScene = MatchmakingScene.newMatchmakingScene()
            self.view?.presentScene(matchmakingScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
        if node.name == "settingsButton" {
            showSettingsMenu()
            return
        }
        if node.name == "settingsBack" {
            settingsMenu.removeFromParent()
        }
        if node.name == "muteSoundsCheckbox" {
            muteSounds.toggle()
            updateMuteCheckbox()
        }
        if node.name == "muteMusicCheckbox" {
            muteMusic.toggle()
            updateMuteCheckbox()
            handleMusicVolume(muteMusic: self.muteMusic)
        }
    }
}



#endif
