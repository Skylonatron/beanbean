//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit

enum GameState {
    case active
    case gravity
    case checkGroups
    case popGroups
    case new
}

class GameScene: SKScene {
    
    // debug settings
    fileprivate var showNumber: Bool = false
    fileprivate var showGridCells: Bool = false
    fileprivate var showGridCellsRowColumn: Bool = false
    fileprivate var printGameState = false
    
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
    
    // movement speeds
    var verticalMovementSpeed : Double = 2
    var fastVerticalMovementSpeed: Double = 10
    var gravitySpeed: Double = 10
    var movementSpeed: Double!
    var fastMovement: Bool = false
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var beans : [Bean] = []
    fileprivate var cellsToExplode: [Cell] = []
    fileprivate var grid : Grid!
    fileprivate var beanPod: BeanPod!
    fileprivate var newBeansGenerated: Bool = false // check: new beans this cycle?
    fileprivate var validBeanPosition: Bool = true // check: both beans above non nil/bean cells
    var score: Score = Score()

    var explosionPause: TimeInterval = 0
    
    var gameState: GameState = .active
    var futureState: GameState?
    
    var scoreLabel: SKLabelNode!
    var nuisanceLabel: SKLabelNode!

    
    
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
        
        movementSpeed = verticalMovementSpeed
        
        let bounds = self.view!.bounds
        var cellSize = Int(bounds.size.width / 11)

        #if os(iOS)
            cellSize = Int(bounds.size.width / 7)
        #endif
        
        score = Score()
        
        // draw board
        let grid = Grid(
            rowCount: 12,
            columnCount: 5,
            cellSize: cellSize,
            bounds: bounds,
            showCells: showGridCells,
            showRowColumn: showGridCellsRowColumn
        )
        self.grid = grid
        
        for (_,cellColumn) in grid.cells {
            for (_, cell) in cellColumn {
                self.addChild(cell.shape)
            }
        }
        
        // Initialize the score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 42
        scoreLabel.fontColor = .green
        addChild(scoreLabel)
        
        
        // Initialize the nuisance label
        nuisanceLabel = SKLabelNode(text: "Beans Sent: 0")
        nuisanceLabel.position = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2 - 50)
        nuisanceLabel.fontName = "Arial"
        nuisanceLabel.fontSize = 42
        nuisanceLabel.fontColor = .green
        addChild(nuisanceLabel)
        
        
        generateNewBeans(showNumber: self.showNumber)
    }
    

    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        
        switch gameState {
        case .active:
            if self.fastMovement {
                self.movementSpeed = self.fastVerticalMovementSpeed
            } else {
                self.movementSpeed = self.verticalMovementSpeed
            }
            
            if beanPod.canMoveDown(grid: self.grid, speed: self.movementSpeed) {
                if self.fastMovement{
                    score.movementPoints += 12/83
                    if score.movementPoints > 1{
                        score.totalPoints += 1
                        score.movementPoints -= 1
                        scoreLabel.text = "Score: \(score.totalPoints)"
                    }
                }
                beanPod.moveDown(speed: self.movementSpeed)
                beanPod.currentTimeOverNil = 0
                beanPod.timeSinceNil += 1/60
                
                if beanPod.timeSinceNil > 1.238 && beanPod.totalTimeNil != 0 {
                    beanPod.timeSinceNil = 0
                    beanPod.totalTimeNil = 0
                }
            }

            
            else {
                // bean pod has hit the ground or a bean
                beanPod.currentTimeOverNil += 1/60 //60 FPS
                beanPod.totalTimeNil += 1/60
                beanPod.timeSinceNil = 0
                let setCells = beanPod.snapToCell(grid: grid)
                
                
                if self.movementSpeed == 10{
                    beanPod.currentTimeOverNil += 2/60
                    beanPod.totalTimeNil += 1/60
                    beanPod.timeSinceNil += 1/60
                }
                
                if beanPod.currentTimeOverNil >= 0.3 || beanPod.totalTimeNil >= beanPod.nilAllowance {
                    beanPod.active = false
                    setCells.0.bean = beanPod.mainBean
                    setCells.1.bean = beanPod.sideBean
                    beanPod.currentTimeOverNil = 0
                    self.beans = self.grid.getBeans()
                    setGameState(state: .gravity)
                }
            }
            // lower all beans that are not on the ground
        case .gravity:
            if self.beans.count == 0 {
                setGameState(state: .active)
            }
            for bean in self.beans {
                let currentCell = grid.getCell(x: bean.shape.position.x, y: bean.shape.position.y)
                
                if bean.canMoveDown(grid: self.grid, speed: self.gravitySpeed) {
                    // release the bean from the cell so others above can move down
                    currentCell?.bean = nil
                    bean.shape.position.y -= self.gravitySpeed
                } else {
                    bean.shape.position = currentCell!.shape.position
                    currentCell!.bean = bean
                    bean.checked = true
                }
            }
            // if all beans can't move down anymore is true then we can move on
            let allBeansAtRest = self.beans.allSatisfy { $0.checked }
            // set checked to false for next time
            for bean in self.beans {
                bean.checked = false
            }
            if allBeansAtRest {
                self.beans = grid.getBeans()
                setGameState(state: .checkGroups)
            }
        case .checkGroups:
            for cell in grid.getCellsWithBeans() {
                cell.mergeAllGroups(grid: grid)
            }
            for cell in grid.getCellsWithBeans() {
                if cell.group.count >= 4 {
                    for cell in cell.group {
                        cell.group = [cell]
                        self.cellsToExplode.append(cell)
                    }
                }
                cell.group = [cell]
            }
            if self.cellsToExplode.count > 0 {
                // find a better way to do this pause
                explosionPause = 0.5
                for cell in self.cellsToExplode {
                    cell.bean?.animationBeforeRemoved()
                }
                setGameState(state: .popGroups)
            } else {
                setGameState(state: .new)
            }
        case .popGroups:
            if explosionPause > 0 {
                explosionPause -= 1/60
                return
            }
            
            self.score.calculateChainStep(cellsToExplode: self.cellsToExplode)
                        
            // add wait here
            for cell in self.cellsToExplode {
                cell.bean?.shape.removeFromParent()
                cell.bean = nil
            }
            
            //finish popping
            
            self.cellsToExplode = []
            self.beans = grid.getBeans()
            setGameState(state: .gravity)
        case .new:
            self.score.sumFullChain()
            scoreLabel.text = "Score: \(score.totalPoints)"
            nuisanceLabel.text = "Beans Sent: \(score.numNuisanceBeans)"
            self.score.reset()
            generateNewBeans(showNumber: self.showNumber)
            setGameState(state: .active)
        }

    }
    
    func setGameState(state: GameState) {
        if printGameState {
            print("Setting state to \(state)")
        }
        gameState = state
        
    }
    
    func generateNewBeans(showNumber: Bool){
        // make another bean
        let colors = [SKColor.purple, SKColor.green, SKColor.red, SKColor.yellow]

        let color = colors.randomElement()!
        let color2 = colors.randomElement()!
        let mainBean = Bean(
            color: color,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.shape.position,
            showNumber: showNumber
        )
        self.addChild(mainBean.shape)
        
        let sideBean = Bean(
            color: color2,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position,
            showNumber: showNumber
        )
        self.addChild(sideBean.shape)
        
        self.beanPod = BeanPod(activeBean: mainBean, sideBean: sideBean)

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
                self.beanPod.moveRight(grid: grid)
            }
            if moveAmtX < -25 {
                initialTouch = movingPoint
                self.beanPod.moveLeft(grid: grid)
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
                self.beanPod.spinPod(grid: self.grid, clockWise: true)
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
            self.fastMovement = false
        }
    }
    override func keyDown(with event: NSEvent) {
        //      2 is D
        if event.keyCode == 2 {
            beanPod.moveRight(grid: grid)
        }
        
        //      0 is A
        if event.keyCode == 0 {
            beanPod.moveLeft(grid: grid)
        }
        //      1 is S
        if event.keyCode == 1 && beanPod.active {
            self.fastMovement = true
        }
        
        
        //      126 is up arrow
        if event.keyCode == 126 {
            self.beanPod.spinPod(grid: self.grid, clockWise: false)
        }
        
        //      125 is down arrow
        if event.keyCode == 125 {
            self.beanPod.spinPod(grid: self.grid, clockWise: true)
        }
        
    }

}
#endif

