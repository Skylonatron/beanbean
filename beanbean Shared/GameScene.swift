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
    fileprivate var beanPod: BeanPod!
    fileprivate var movementSpeed : Double = 1
    fileprivate var gravity : Double = 10
    fileprivate var newBeansGenerated: Bool = false // check: new beans this cycle?
    fileprivate var validBeanPosition: Bool = true // check: both beans above non nil/bean cells
    fileprivate var allBeansAtRest: Bool = false
    fileprivate var beansPopped: Bool = false
    
    
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
        
        //initialize side bean
        let sideBean = Bean(color: SKColor.green, cellSize: cellSize, startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position)
        self.addChild(sideBean.shape)
        self.beans.append(sideBean)
        
        self.beanPod = BeanPod(activeBean: bean, sideBean: sideBean)
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // keep side bean around active bean
//        self.sideBean.shape.position.x = self.activeBean.shape.position.x + CGFloat(grid.cellSize)
//        self.sideBean.shape.position.y = self.activeBean.shape.position.y
        
        if beanPod.active {
            
            if beanPod.canMoveDown(grid: self.grid, speed: self.movementSpeed) {
                beanPod.moveDown(speed: self.movementSpeed)
                beanPod.elapsedTime = 0
            } else {
                // bean pod has hit the ground or a bean
                beanPod.elapsedTime += 1/60 //60 FPS
                let setCells = beanPod.snapToCell(grid: grid)
                    
                if beanPod.elapsedTime >= 0.3 {
                    beanPod.active = false
                    setCells.0.bean = beanPod.mainBean
                    setCells.1.bean = beanPod.sideBean
                    allBeansAtRest = false
                    beanPod.elapsedTime = 0
                    
                }
            }
    
        // lower all beans that are not on the ground
        } else if allBeansAtRest == false {
            if self.beans.count == 0 {
                allBeansAtRest = true
            }
            for (i, bean) in self.beans.enumerated().reversed() {
                if bean.markForDelete {
                    self.beans.remove(at: i)
                    continue
                }
                
                let currentCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y)
                let futureCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y - self.gravity)
                
                if futureCell == nil || futureCell?.bean != nil {
                    bean.shape.position = currentCell!.shape.position
                    currentCell!.bean = bean
                    bean.checked = true
                } else {
                    currentCell?.bean = nil
                    bean.shape.position.y -= self.gravity
                }
            }
            allBeansAtRest = self.beans.allSatisfy { $0.checked }
            for bean in self.beans {
                bean.checked = false
            }
            if allBeansAtRest {
                beansPopped = false
            }
        // pop
        } else if beansPopped == false {
            for (_,cellColumn) in grid.cells {
                for (_, cell) in cellColumn {
                    if cell.bean != nil {
                        cell.mergeAllGroups(grid: grid)
                    }
                }
            }
            for (_,cellColumn) in grid.cells {
                for (_, cell) in cellColumn {
                    
                    if cell.group.count >= 4 {
                        Thread.sleep(forTimeInterval: 0.3)

                        for cell in cell.group {
                            cell.bean?.shape.removeFromParent()
                            cell.bean?.markForDelete = true
                            cell.bean = nil
                            cell.group = [cell]
                            allBeansAtRest = false
                        }
                    }
                    cell.group = [cell]
                }
            }
            beansPopped = true
            
        } else {
            self.generateNewBeans()
        }
        
//        for bean in self.beans {
//            if bean.active {
//                
//                let currentCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y)
//                let futureCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y - self.movementSpeed)
//                
//                // stops moving
//                if futureCell == nil || futureCell?.bean != nil {
//
//                    //start timer
//                    bean.elapsedTime += 1/60 //60 FPS
//                    if bean.elapsedTime >= 0.3 {
//                        
//                        bean.shape.position = currentCell!.shape.position
//                        bean.active = false
//                        currentCell!.bean = bean
//                        bean.elapsedTime = 0
//                        
//                        currentCell?.mergeAllGroups(grid: self.grid)
//                    }
//                } else {
//                    bean.elapsedTime = 0
//                    bean.shape.position.y -= self.movementSpeed
//                }
//            }
//        }
        
        //only one bean is moving AKA gravity
//        if !activeBean.active && sideBean.active || activeBean.active && !sideBean.active {
//            
//            self.movementSpeed = 12
//        }
        
        // both beans are not moving anymore
//        if !activeBean.active && !sideBean.active {
//            self.movementSpeed = 4
//            self.generateNewBeans()
//        }
    }
    
    func generateNewBeans(){
        // make another bean
        let colors = [SKColor.green, SKColor.yellow, SKColor.red, SKColor.purple]

        let color = colors.randomElement()!
        let color2 = colors.randomElement()!
        let mainBean = Bean(
            color: color,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.shape.position
        )
        self.addChild(mainBean.shape)
        self.beans.append(mainBean)
        
        let sideBean = Bean(
            color: color2,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position
        )
        self.addChild(sideBean.shape)
        self.beans.append(sideBean)
        
        self.beanPod = BeanPod(activeBean: mainBean, sideBean: sideBean)
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
        let location = event.location(in: self)
        let cell = self.grid.getCell(x: location.x + CGFloat(self.grid.cellSize / 2), y: location.y + CGFloat(self.grid.cellSize / 2))
//        print(cell?.column, cell?.row)
        print(cell?.bean)
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
            self.movementSpeed = 1
        }
    }
    override func keyDown(with event: NSEvent) {
//      2 is D
        if event.keyCode == 2 {
            if beanPod.canMoveRight(grid: self.grid) {
                beanPod.moveRight(grid: grid)
            }
        }
        
//      0 is A
        if event.keyCode == 0 && beanPod.active {
            if beanPod.canMoveLeft(grid: grid) {
                beanPod.moveLeft(grid: grid)
            }
            
        }
//      1 is S
        if event.keyCode == 1 && beanPod.active {
            self.movementSpeed = 10
        }
    }

}
#endif

