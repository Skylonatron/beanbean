//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit

class GameScene: SKScene {
        
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
    
    var game: Game!
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        let bounds = self.view!.bounds
        let cellSize = Int(bounds.size.width / 11)
        #if os(iOS)
            cellSize = Int(bounds.size.width / 7)
        #endif
        let columnCount = 5
        let rowCount = 12
        
        let gameParams = GameParams(
            scene: self,
            cellSize: cellSize,
            rowCount: rowCount,
            columnCount: columnCount,
            bounds: bounds
        )
        self.game = Game(params: gameParams)
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        game.update()
    }

}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            initialTouch = touch.location(in: self.scene?.view)
            moveAmtX = 0
            moveAmtY = 0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let movingPoint: CGPoint = t.location(in: self.scene?.view)
            
            moveAmtX = movingPoint.x - initialTouch.x
            moveAmtY = movingPoint.y - initialTouch.y
                        
            if moveAmtX > 25 {
                initialTouch = movingPoint
                self.game.beanPod.moveRight(grid: grid)
            }
            if moveAmtX < -25 {
                initialTouch = movingPoint
                self.game.beanPod.moveLeft(grid: grid)
            }
            if moveAmtY > 35 {
                self.fastMovement = true
            } else {
                self.fastMovement = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            self.fastMovement = false
            if moveAmtX == 0 {
                self.game.beanPod.spinPod(grid: self.grid, clockWise: true)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        // for debugging you can click on a cell and see if there is a bean there
//        let location = event.location(in: self)
//        let cell = self.grid.getCell(x: location.x + CGFloat(self.grid.cellSize / 2), y: location.y + CGFloat(self.grid.cellSize / 2))
//        print(cell?.bean)
    }
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }
    override func keyUp(with event: NSEvent) {
        game.keyUp(event: event)
    }
    override func keyDown(with event: NSEvent) {
        game.keyDown(event: event)
    }
}
#endif

