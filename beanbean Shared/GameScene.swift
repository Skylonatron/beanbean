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
    var match: GKMatch?
    var localPlayerID: String?
    
    
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
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
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
            gamePlayer2.useCPUControls = self.player2CPU
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

}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        games[0].touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        // Check if touch intersects with the node's frame
        if node.name == "New Game" {
            self.newGamePushed = true
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        games[0].touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        games[0].touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        // Check if touch intersects with the node's frame
        if node.name == "New Game" && self.newGamePushed == true {
            for game in games {
                game.startNewGame()
            }
            self.newGamePushed = false
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



