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
    fileprivate var activeBean: Bean!
    fileprivate var sideBean: Bean!
    fileprivate var grid : Grid!
    fileprivate var movementSpeed : Double = 4
    fileprivate var newBeansGenerated: Bool = false // check: new beans this cycle?
    fileprivate var validBeanPosition: Bool = true // check: both beans above non nil/bean cells
    
    
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
        
        for (_,cellColumn) in grid.cells {
            for (_, cell) in cellColumn {
                self.addChild(cell.shape)
            }
        }

        
        // initialize main bean
        let bean = Bean(color: SKColor.green, cellSize: cellSize, startingPosition: grid.getStartingCell()!.shape.position)
        self.addChild(bean.shape)
        self.beans.append(bean)
        self.activeBean = bean
        
        //initialize side bean
        let sideBean = Bean(color: SKColor.green, cellSize: cellSize, startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position)
        self.addChild(sideBean.shape)
        self.beans.append(sideBean)
        self.sideBean = sideBean
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        self.sideBean.shape.position.x = self.activeBean.shape.position.x + CGFloat(grid.cellSize)
        
        for bean in self.beans {
            if bean.active {
                
                let currentCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y)
                let futureCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y - self.movementSpeed)
                
                // stops moving
                if futureCell == nil || futureCell?.bean != nil {
                    //start timer
                    bean.elapsedTime += 1/60 //60 FPS
                    if bean.elapsedTime >= 0.3 {
                        
                        bean.shape.position = currentCell!.shape.position
                        bean.active = false
                        currentCell!.bean = bean
                        bean.elapsedTime = 0
                        
                        currentCell?.mergeAllGroups(grid: self.grid)
                    }
                } else {
                    bean.elapsedTime = 0
                    bean.shape.position.y -= self.movementSpeed
                }
            }
        }
        
        //only one bean is moving AKA gravity
        if !activeBean.active && sideBean.active || activeBean.active && !sideBean.active {
            
            self.movementSpeed = 12
        }
        
        // both beans are not moving anymore
        if !activeBean.active && !sideBean.active {
            self.movementSpeed = 4
            self.generateNewBeans()
        }
    }
    
    func generateNewBeans(){
        // make another bean
        let colors = [SKColor.green, SKColor.yellow, SKColor.red, SKColor.purple]
        let color = colors.randomElement()!
        let color2 = colors.randomElement()!
        let bean = Bean(
            color: color,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.shape.position
        )
        self.activeBean = bean
        self.addChild(bean.shape)
        self.beans.append(bean)
        
        let sideBean = Bean(
            color: color2,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position
        )
        self.sideBean = sideBean
        self.addChild(sideBean.shape)
        self.beans.append(sideBean)
        
        
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
    }
    override func keyUp(with event: NSEvent) {
//      1 is S
        if event.keyCode == 1 {
            self.movementSpeed = 4
        }
    }
    override func keyDown(with event: NSEvent) {
//      2 is D
        if event.keyCode == 2 && activeBean.active && sideBean.active {
            let currentCell = grid.getCell(x: activeBean.shape.position.x, y: activeBean.shape.position.y)
            let futureCell = grid.cells[currentCell!.column + 1]?[currentCell!.row]
            let currentCellSide = grid.getCell(x: sideBean.shape.position.x, y: sideBean.shape.position.y)
            let futureCellSide = grid.cells[currentCellSide!.column + 1]?[currentCellSide!.row]
            if futureCell != nil && futureCell!.bean == nil && futureCellSide != nil && futureCellSide!.bean == nil {
                activeBean.shape.position.x = futureCell!.shape.position.x
            }
        }
        
//      0 is A
        if event.keyCode == 0 && activeBean.active && sideBean.active {
            let currentCell = grid.getCell(x: activeBean.shape.position.x, y: activeBean.shape.position.y)
            let futureCell = grid.cells[currentCell!.column-1]?[currentCell!.row]
            let currentCellSide = grid.getCell(x: sideBean.shape.position.x, y: sideBean.shape.position.y)
            let futureCellSide = grid.cells[currentCellSide!.column - 1]?[currentCellSide!.row]
            if futureCell != nil && futureCell!.bean == nil && futureCellSide != nil && futureCellSide!.bean == nil{
                activeBean.shape.position.x = futureCell!.shape.position.x
            }
        }
//      1 is S
        if event.keyCode == 1 && activeBean.active && sideBean.active {
            self.movementSpeed = 8
        }
    }

}
#endif

