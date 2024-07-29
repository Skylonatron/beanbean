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
    var settingsButton: SKSpriteNode!
    var muteMusicCheckbox: SKSpriteNode!
    var muteSoundsCheckbox: SKSpriteNode!
    var settingsDisplayed: Bool = false
    var muteSounds: Bool = false
    var muteMusic: Bool = true
    
        
    class func newHomeScene() -> HomeScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = HomeScene()
        
        // Set the scale mode to scale to fit the window
//        scene.scaleMode = .aspectFll
        
        return scene
    }
    
    func setUpScene() {
        let background = SKSpriteNode(imageNamed: "homescreen") // Replace with your image name
          background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
          background.size = self.size
          background.zPosition = -1 // Ensure the background is behind other nodes
          self.addChild(background)
        
//        let outline = outline(
//            width: self.size.width / 2,
//            height: self.size.height / 2,
//            lineWidth: 8
//        )
//        self.addChild(outline)

        let soloButton = addButton(outlineFrame: self.frame, name: "Solo")
        soloButton.position = CGPoint(x: 0, y: frame.height / 16)
        self.addChild(soloButton)
        
        let multiButton = addButton(outlineFrame: self.frame, name: "Multi")
        multiButton.position = CGPoint(x: 0, y: -frame.height / 20)
        self.addChild(multiButton)
        
        let matchmakingButton = addButton(outlineFrame: self.frame, name: "Online")
        matchmakingButton.position = CGPoint(x: 0, y: -frame.height / 6)
        self.addChild(matchmakingButton)
        
        muteMusicCheckbox = SKSpriteNode(imageNamed: muteMusic ? "music-icon-mute" : "music-icon")
        muteMusicCheckbox.size = CGSize(width: 50, height: 50)
        muteMusicCheckbox.position = CGPoint(x: frame.width / 2.5, y: frame.height / 2.21)
        muteMusicCheckbox.name = "muteMusicCheckbox"
        muteMusicCheckbox.zPosition = 2
        muteMusicCheckbox.isHidden = true
        self.addChild(muteMusicCheckbox)
        
        muteSoundsCheckbox = SKSpriteNode(imageNamed: muteSounds ? "sound-icon-mute" : "sound-icon")
        muteSoundsCheckbox.size = CGSize(width: 50, height: 50)
        muteSoundsCheckbox.position = CGPoint(x: frame.width / 2.5, y: frame.height / 2.2)
        muteSoundsCheckbox.name = "muteSoundsCheckbox"
        muteSoundsCheckbox.zPosition = 1
        muteSoundsCheckbox.isHidden = true
        self.addChild(muteSoundsCheckbox)
        
        settingsButton = SKSpriteNode(imageNamed: "settings")
        settingsButton.size = CGSize(width: 50, height: 50)
        settingsButton.position = CGPoint(x: frame.width / 2.5, y: frame.height / 2.2)
        settingsButton.name = "settingsButton"
        settingsButton.zPosition = 3
        self.addChild(settingsButton)
    }
    
    func addButton(outlineFrame: CGRect, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(
            width: frame.width / 4,
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
        labelNode.fontSize = 32
        labelNode.fontName = "ChalkboardSE-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        button.addChild(labelNode) // Add label as child of shape node
        return button  
    }
    

    
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
//        self.size = CGSize(width: 1366.0, height: 1024.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setUpScene()
        playBackgroundMusic(muteMusic: self.muteMusic)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    func showSettingsMenu() {
        muteMusicCheckbox.isHidden = false
        muteSoundsCheckbox.isHidden = false
        
        var moveDown = SKAction.moveBy(x: 0, y: -muteMusicCheckbox.size.height, duration: 0.5)
        muteMusicCheckbox.run(moveDown)
        
        moveDown = SKAction.moveBy(x: 0, y: -muteSoundsCheckbox.size.height * 2 - 7, duration: 0.5)
        muteSoundsCheckbox.run(moveDown)
    }
    
    func hideSettingsMenu() {
        
        var moveDown = SKAction.moveBy(x: 0, y: muteMusicCheckbox.size.height, duration: 0.5)
        muteMusicCheckbox.run(moveDown) {
            self.muteMusicCheckbox.isHidden = true
        }
        
        moveDown = SKAction.moveBy(x: 0, y: muteSoundsCheckbox.size.height * 2 + 7, duration: 0.5)
        muteSoundsCheckbox.run(moveDown) {
            self.muteSoundsCheckbox.isHidden = true
        }
    }
    
    
    func updateMuteCheckbox() {
        if let muteMusicCheckbox = self.childNode(withName: "muteMusicCheckbox") as? SKSpriteNode {
            let newTexture = SKTexture(imageNamed: muteMusic ? "music-icon-mute" : "music-icon")
            muteMusicCheckbox.texture = newTexture
        }
        if let muteSoundsCheckbox = self.childNode(withName: "muteSoundsCheckbox") as? SKSpriteNode {
            let newTexture = SKTexture(imageNamed: muteSounds ? "sound-icon-mute" : "sound-icon")
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
        if node.name == "settingsButton"{
            if self.settingsDisplayed == true {
                hideSettingsMenu()
                let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
                settingsButton.run(rotateAction)
                self.settingsDisplayed = false
            } else {
                showSettingsMenu()
                let rotateAction = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 0.5)
                settingsButton.run(rotateAction)
                self.settingsDisplayed = true
            }
            
            return
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
