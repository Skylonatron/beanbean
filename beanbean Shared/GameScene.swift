//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//

import SpriteKit

class GameScene: SKScene {
    
    fileprivate var label : SKLabelNode?
    fileprivate var beans : [Bean] = []
    fileprivate var grid : Grid!
    
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
        
        // todo make create board into function
        // draw board
        let grid = Grid(rowCount: 12, columnCount: 6, cellSize: cellSize, bounds: bounds, showCells: true)
        self.grid = grid
//        self.addChild(grid.shape)
        
        for (_,cell) in grid.cells {
            self.addChild(cell.shape)
        }

        let bean = Bean(color: SKColor.green, cellSize: cellSize)
        self.addChild(bean.shape)
        self.beans.append(bean)
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        for bean in self.beans {
            if bean.active {
                
                let cord = grid.getCellCord(x: bean.shape.position.x, y: bean.shape.position.y + Double(grid.cellSize / 2))
                let cordY = cord.1
                print(cordY)
                if CGFloat(cordY) > 0 {
                    bean.shape.position.y -= 4
                }
                let corda = grid.getCellCord(x: bean.shape.position.x, y: bean.shape.position.y + Double(grid.cellSize / 2))
                let cordYa = corda.1
                print(cordYa)
            }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
        
        for t in touches {
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
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
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let cord = self.grid.getCellCord(x: location.x, y: location.y)
        print(cord.0, cord.1)

        
    }

}
#endif

