//
//  Game.swift
//  beanbean
//
//  Created by Skylar Jones on 3/22/24.
//

import SpriteKit

enum GameState {
    case active
    case gravity
    case checkGroups
    case popGroups
    case new
}

struct GameParams {
    let scene: SKScene
    let cellSize: Int
    let rowCount: Int
    let columnCount: Int
    let bounds: NSRect
}

class Game {
    
    var gameState: GameState = .new
    var beans : [Bean] = []
    var cellsToExplode: [Cell] = []
    var grid : Grid!
    var beanPod: BeanPod!
    var score: Score!
    var explosionPause: TimeInterval = 0
    var movementSpeed: Double = 0
    var fastMovement: Bool = false
    var scene: SKScene
        
    init(params: GameParams){
        self.scene = params.scene
        
        self.score = Score(bounds: params.bounds)
        self.scene.addChild(score.scoreLabel)
        self.scene.addChild(score.nuisanceLabel)
        
        self.grid = Grid(
            rowCount: params.rowCount,
            columnCount: params.columnCount,
            cellSize: params.cellSize,
            showCells: settings.debug.showCells,
            showRowColumn: settings.debug.showRowColumnNumbers
        )
        for (_,cellColumn) in grid.cells {
            for (_, cell) in cellColumn {
                params.scene.addChild(cell.shape)
            }
        }
    }
    
    func update() {
        switch gameState {
        case .active:
            if self.fastMovement {
                self.movementSpeed = settings.movement.fastVerticalSpeed
            } else {
                self.movementSpeed = settings.movement.defaultVerticalSpeed
            }
            
            if beanPod.canMoveDown(grid: self.grid, speed: self.movementSpeed) {
                if self.fastMovement{
                    score.movementPoints += 12/83
                    if score.movementPoints > 1{
                        score.totalPoints += 1
                        score.movementPoints -= 1
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
                
                
                if self.fastMovement{
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
                
                if bean.canMoveDown(grid: self.grid, speed: settings.movement.gravitySpeed) {
                    // release the bean from the cell so others above can move down
                    currentCell?.bean = nil
                    bean.shape.position.y -= settings.movement.gravitySpeed
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
                for cell in self.cellsToExplode {
                    cell.bean?.animationBeforeRemoved()
                }
                setGameState(state: .popGroups)
            } else {
                setGameState(state: .new)
            }
        case .popGroups:
            if explosionPause < 0.5 {
                explosionPause += 1/60
                return
            }
            explosionPause = 0
            
            self.score.calculateChainStep(cellsToExplode: self.cellsToExplode)
                        
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
            self.score.reset()
            generateNewBeans(showNumber: settings.debug.showGroupNumber)
            setGameState(state: .active)
        }
    }
    
    func setGameState(state: GameState) {
        if settings.debug.printGameState {
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
        self.scene.addChild(mainBean.shape)
        
        let sideBean = Bean(
            color: color2,
            cellSize: grid.cellSize,
            startingPosition: grid.getStartingCell()!.getRightCell(grid: grid)!.shape.position,
            showNumber: showNumber
        )
        self.scene.addChild(sideBean.shape)
        
        self.beanPod = BeanPod(activeBean: mainBean, sideBean: sideBean)

    }
    
    func keyUp(event: NSEvent) {
        //      1 is S
        if event.keyCode == 1 {
            self.fastMovement = false
        }
    }
    
    func keyDown(event: NSEvent) {
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
