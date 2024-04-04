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
}

class GameScene: SKScene {
        
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
    var gameMode: GameMode = .single
    
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
            cellSize = Int(bounds.size.width / 7)
        #endif
        let columnCount = 5
        let rowCount = 12
        let controller1 = Controller(
            up: Keycode.w,
            down: Keycode.s,
            right: Keycode.d,
            left: Keycode.a,
            spinClockwise: Keycode.upArrow,
            spinCounter: Keycode.downArrow
        )
        
        var player: Int?
        if gameMode == .localMultiplayer {
            player = 1
            let controller2 = Controller(
                up: Keycode.i,
                down: Keycode.k,
                right: Keycode.l,
                left: Keycode.j,
                spinClockwise: Keycode.semicolon,
                spinCounter: Keycode.apostrophe
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
                samBot: samBot()
            )

            let gameParamsPlayer1 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller1,
                player: player,
                otherPlayerGame: nil,
                samBot: samBot()
            )
            
            //add games to array and set otherPlayerGame
            let gamePlayer1 = Game(params: gameParamsPlayer1)
            let gamePlayer2 = Game(params: gameParamsPlayer2)
            gamePlayer1.useCPUControls = false
            self.games.append(gamePlayer1)
            self.games.append(gamePlayer2)
            gamePlayer1.otherPlayerGame = gamePlayer2
            gamePlayer2.otherPlayerGame = gamePlayer1
            
            
        }
        else{
            let gameParamsPlayer1 = GameParams(
                scene: self,
                cellSize: cellSize,
                rowCount: rowCount,
                columnCount: columnCount,
                bounds: bounds,
                controller: controller1,
                player: player,
                otherPlayerGame: nil,
                samBot: samBot()
            )
            let gamePlayer1 = Game(params: gameParamsPlayer1)
            self.games.append(gamePlayer1)
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



