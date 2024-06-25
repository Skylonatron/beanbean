//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss


import SpriteKit
import GameKit

enum GameMode {
    case single
    case localMultiplayer
    case onlineMultiplayer
}

class GameScene: SKScene {
        
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
    var gameMode: GameMode = .single
    var player2CPU: Bool = true
    var totalGamesWon: Int = 0
    var newGamePushed: Bool = false
    var backPushed: Bool = false
    var match: GKMatch?
    var localPlayerID: String?
    var pauseButton: SKSpriteNode!
    var pauseMenu: SKNode!
    var settingsMenu: SKNode!
    var leaderboardShowing: Bool = false
    var muteSounds: Bool = false
    var muteMusic: Bool = true
    
    var games: [Game] = []
    
    class func newGameScene(mode: GameMode, match: GKMatch? = nil) -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
//        let scene = GameScene()
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.match = match
        scene.gameMode = mode
        scene.localPlayerID = GKLocalPlayer.local.gamePlayerID
        
        return scene

    }
    
    func setUpScene() {
        let bounds = self.view!.bounds
        var cellSize = Int(bounds.size.width / 11)
        #if os(iOS)
        cellSize = Int(bounds.size.width / 5.5)
        #endif
        let columnCount = 5
        let rowCount = 12
        let seed = UInt64.random(in: 0...1000000)
        // Set up your pause button
        self.pauseButton = SKSpriteNode(imageNamed: "transparentDark12")
        self.pauseButton.position = CGPoint(x: bounds.size.width / 2.6, y: bounds.size.height / 2.6)
        self.pauseButton.zPosition = 20
        self.addChild(self.pauseButton)
        
        let controller1 = Controller(
            up: Keycode.w,
            down: Keycode.s,
            right: Keycode.d,
            left: Keycode.a,
            spinClockwise: Keycode.upArrow,
            spinCounter: Keycode.downArrow
        )
        
        switch gameMode {
        case .single:
            let gameParams = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller1,
                player: nil,
                otherPlayerGame: nil,
                samBot: samBot(),
                seed: seed,
                gameMode: self.gameMode,
                match: nil
                
            )
            
            self.games.append(Game(params: gameParams))
        case .localMultiplayer:
            let controller2 = Controller(
                up: Keycode.i,
                down: Keycode.k,
                right: Keycode.l,
                left: Keycode.j,
                spinClockwise: Keycode.semicolon,
                spinCounter: Keycode.apostrophe
            )
            
            let gameParamsPlayer1 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller1,
                player: 1,
                otherPlayerGame: nil,
                samBot: samBot(),
                seed: seed,
                gameMode: self.gameMode,
                match: nil
            )
            
            let gameParamsPlayer2 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller2,
                player: 2,
                otherPlayerGame: nil,
                samBot: samBot(),
                seed: seed,
                gameMode: self.gameMode,
                match: nil
            )
            
            //add games to array and set otherPlayerGame
            let gamePlayer1 = Game(params: gameParamsPlayer1)
            let gamePlayer2 = Game(params: gameParamsPlayer2)
            gamePlayer2.useCPUControls = self.player2CPU
            self.games.append(gamePlayer1)
            self.games.append(gamePlayer2)
            gamePlayer1.otherPlayerGame = gamePlayer2
            gamePlayer2.otherPlayerGame = gamePlayer1
        case .onlineMultiplayer:
            let controller2 = Controller(
                up: Keycode.i,
                down: Keycode.k,
                right: Keycode.l,
                left: Keycode.j,
                spinClockwise: Keycode.semicolon,
                spinCounter: Keycode.apostrophe
            )
            
            let gameParamsPlayer1 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller1,
                player: 1,
                otherPlayerGame: nil,
                samBot: samBot(),
                seed: seed,
                gameMode: self.gameMode,
                match: self.match
            )
            
            let gameParamsPlayer2 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller2,
                player: 2,
                otherPlayerGame: nil,
                samBot: samBot(),
                seed: seed,
                gameMode: self.gameMode,
                match: self.match
            )
            
            //add games to array and set otherPlayerGame
            let gamePlayer1 = Game(params: gameParamsPlayer1)
            let gamePlayer2 = Game(params: gameParamsPlayer2)
//            gamePlayer2.useCPUControls = self.player2CPU
            gamePlayer1.otherPlayerGame = gamePlayer2
            gamePlayer2.otherPlayerGame = gamePlayer1
            self.games.append(gamePlayer1)
            self.games.append(gamePlayer2)
        }
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for game in games {
            game.update()
        }
    }
    
    func showPauseMenu() {
        pauseMenu = SKNode()
        pauseMenu.zPosition = 20
        

        let background = SKSpriteNode(
            color: .white,
            size: CGSize(width: self.view!.bounds.width / 1.3, height: self.view!.bounds.height / 2.5)
        )
        background.alpha = 0.90
        background.position = CGPoint(x: 0, y: 0)
        pauseMenu.addChild(background)
        
        let yOffset = background.size.height / 4

        let resumeButton = SKLabelNode(text: "Resume")
        resumeButton.position = CGPoint(x: 0, y: background.size.height / 3)
        resumeButton.name = "resumeButton"
        resumeButton.fontColor = .black
        pauseMenu.addChild(resumeButton)

        let restartButton = SKLabelNode(text: "Restart")
        restartButton.position = CGPoint(x: 0, y: background.size.height / 3 - yOffset)
        restartButton.name = "restartButton"
        restartButton.fontColor = .black
        pauseMenu.addChild(restartButton)

        let mainMenuButton = SKLabelNode(text: "Main Menu")
        mainMenuButton.position = CGPoint(x: 0, y: background.size.height / 3 - 2 * yOffset)
        mainMenuButton.name = "mainMenuButton"
        mainMenuButton.fontColor = .black
        pauseMenu.addChild(mainMenuButton)
        
        let settingsButton = SKLabelNode(text: "Settings")
        settingsButton.position = CGPoint(x: 0, y: background.size.height / 3 - 3 * yOffset)
        settingsButton.name = "settingsButton"
        settingsButton.fontColor = .black
        pauseMenu.addChild(settingsButton)

        self.addChild(pauseMenu)
    }
    
    func showSettingsMenu() {
        settingsMenu = SKNode()
        settingsMenu.zPosition = 21
        

        let background = SKSpriteNode(
            color: .white,
            size: CGSize(width: self.view!.bounds.width / 1.3, height: self.view!.bounds.height / 2.5)
        )
        background.alpha = 0.90
        background.position = CGPoint(x: 0, y: 0)
        settingsMenu.addChild(background)
        
        if backgroundMusicPlayer?.isPlaying == false {
            self.muteMusic = true
        }
        
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
        for game in games {
            game.muteSounds = self.muteSounds
            game.muteMusic = self.muteMusic
        }
        
    }

}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused == true {
            return
        }
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        // Check if touch intersects with the node's frame
        if node.name == "New Game" && !self.leaderboardShowing {
            self.newGamePushed = true
        }
        
        if node.name == "Leaderboard" && !self.leaderboardShowing {
            games[0].showLeaderboard()
            self.leaderboardShowing = true
        }
        
        if node.name == "Back" && self.leaderboardShowing {
            self.backPushed = true
        }
        
        if self.isPaused != true {
            games[0].touchesBegan(touches, with: event)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused == true {
            return
        }
        games[0].touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        if self.isPaused == true {
            if node.name == "resumeButton" {
                self.isPaused = false
                pauseMenu.removeFromParent()
                return
            }
            if node.name == "restartButton" {
                pauseMenu.removeFromParent()
                let gameScene = GameScene.newGameScene(mode: self.gameMode)
                self.view?.presentScene(gameScene)
            }
            if node.name == "mainMenuButton" {
                pauseMenu.removeFromParent()
                let scene = HomeScene.newHomeScene()
                
                // Present the scene
                let skView = self.view as! SKView
                skView.presentScene(scene)
                
                skView.ignoresSiblingOrder = true
                
                skView.showsFPS = true
                skView.showsNodeCount = true
            }
            if node.name == "settingsButton" {
                pauseMenu.removeFromParent()
                showSettingsMenu()
                return
            }
            if node.name == "settingsBack" {
                settingsMenu.removeFromParent()
                showPauseMenu()
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
            return
        } else if pauseButton.contains(touchLocation) {
            self.isPaused = true
            showPauseMenu()
            return
        }
        
        games[0].touchesEnded(touches, with: event)
        
        
        // Check if touch intersects with the node's frame
        if node.name == "New Game" && self.newGamePushed == true && !self.leaderboardShowing{
            for game in games {
                game.startNewGame()
            }
            self.newGamePushed = false
        }
        
        if node.name == "Back" && self.backPushed == true && self.leaderboardShowing {
            if let leaderboardMenu = games[0].scene.childNode(withName: "leaderboardMenu") {
                leaderboardMenu.removeFromParent()
            }
            self.backPushed = false
            self.leaderboardShowing = false
        }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
//        let location = event.location(in: self)
//        let node = self.atPoint(location)
//        print(node.name)
//        if node.name == "New Game" && game.gameState == .endScreen {
//            self.scene?.removeAllChildren()
//            game.gameOver = false
//            let gameScene = GameScene.newGameScene(mode: .single)
//            self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
//        }
    }
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }
    override func keyUp(with event: NSEvent) {
        for game in games {
            game.keyUp(event: event)
        }
    }
    override func keyDown(with event: NSEvent) {
        for game in games {
            game.keyDown(event: event)
        }
    }
}
#endif



