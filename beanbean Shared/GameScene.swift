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
    fileprivate var allBeansAtRest: Bool = true
    fileprivate var checkbeansForPop: Bool = false
    
    
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
        
        // draw board
        let grid = Grid(rowCount: 12, columnCount: 6, cellSize: cellSize, bounds: bounds, showCells: true)
        self.grid = grid
        
        for (_,cellColumn) in grid.cells {
            for (_, cell) in cellColumn {
                self.addChild(cell.shape)
            }
        }
        
        generateNewBeans()
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
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
                    self.beans = self.grid.getBeans()
                }
            }
    
        // lower all beans that are not on the ground
        } else if allBeansAtRest == false {
            if self.beans.count == 0 {
                allBeansAtRest = true
                // todo skip rest of logic in this case
            }
            for bean in self.beans {
                let currentCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y)
                
                if bean.canMoveDown(grid: self.grid, speed: self.gravity) {
                    // release the bean from the cell so others above can move down
                    currentCell?.bean = nil
                    bean.shape.position.y -= self.gravity
                } else {
                    bean.shape.position = currentCell!.shape.position
                    currentCell!.bean = bean
                    bean.checked = true
                }
            }
            // if all beans can't move down anymore is true then we can move on
            allBeansAtRest = self.beans.allSatisfy { $0.checked }
            // set checked to false for next time
            for bean in self.beans {
                bean.checked = false
            }
            if allBeansAtRest {
                self.beans = grid.getBeans()
                checkbeansForPop = true
            }
        // pop
        } else if checkbeansForPop == true {
            for cell in grid.getCellsWithBeans() {
                cell.mergeAllGroups(grid: grid)
            }
            var cellsToExplode: [Cell] = []
            for cell in grid.getCellsWithBeans() {
                if cell.group.count >= 4 {
                    for cell in cell.group {
                        cell.group = [cell]
                        cellsToExplode.append(cell)
                    }
                }
                cell.group = [cell]
            }
            if cellsToExplode.count > 0 {
                Thread.sleep(forTimeInterval: 0.5)
                allBeansAtRest = false
            }
            for cell in cellsToExplode {
                cell.bean?.shape.removeFromParent()
                cell.bean = nil
            }
            checkbeansForPop = false
            self.beans = grid.getBeans()

        } else {
            self.generateNewBeans()
        }
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
        
        let sideBean = Bean(
            color: color2,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position
        )
        self.addChild(sideBean.shape)
        
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
        // for debugging you can click on a cell and see if there is a bean there
        let location = event.location(in: self)
        let cell = self.grid.getCell(x: location.x + CGFloat(self.grid.cellSize / 2), y: location.y + CGFloat(self.grid.cellSize / 2))
        print(cell?.bean)
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
        
        
        //      126 is up arrow
        if event.keyCode == 126 {
            self.beanPod.spinPod(grid: self.grid)
        }
        
//        //      125 is down arrow
//        if event.keyCode == 126 {
//            self.beanPod.spinPodCW(grid: self.grid, direction: -1)
//        }
        
    }

}
#endif

