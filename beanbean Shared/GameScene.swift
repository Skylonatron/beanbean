//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss


import SpriteKit

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
    
    
    var games: [Game] = []
    
    class func newGameScene(mode: GameMode) -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
//        let scene = GameScene()
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        scene.gameMode = mode
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
                gameMode: self.gameMode
                
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
                gameMode: self.gameMode
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
                gameMode: self.gameMode
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
                gameMode: self.gameMode
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
                gameMode: self.gameMode
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
        for game in games {
            game.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for game in games {
            game.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for game in games {
            game.touchesEnded(touches, with: event)
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



