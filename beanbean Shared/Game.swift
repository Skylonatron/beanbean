//
//  Game.swift
//  beanbean
//
//  Created by Skylar Jones on 3/22/24.
//

import SpriteKit
import GameKit

enum GameState {
    case active
    case gravity
    case checkGroups
    case popGroups
    case new
    case endScreen
    case dropNuisanceBeans
}

struct GameParams {
    let scene: SKScene
    let cellSize: Int
    let rowCount: Int
    let columnCount: Int
    let bounds: CGRect
    let controller: Controller
    let player: Int?
}

class Game {
    var num: Int!
    var gameState: GameState = .new
    var beans : [Bean] = []
    var cellsToExplode: [Cell] = []
    var cellsToExplodeWithNuisance: [Cell] = []
    var grid : Grid!
    var beanPod: BeanPod!
    var score: Score!
    var explosionPause: TimeInterval = 0
    var movementSpeed: Double = 0
    var fastMovement: Bool = false
    var scene: SKScene
    var bounds: CGRect
    let controller: Controller
    var gameOver = false
    
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
        
    init(params: GameParams){
        self.scene = params.scene
        self.bounds = params.bounds
        
        self.score = Score(bounds: params.bounds, scene: params.scene)
        self.scene.addChild(score.scoreOutline)
        self.scene.addChild(score.highScoreOutline)
        self.controller = params.controller
        
        Task {
            await loadLeaderboard()
        }
        
        var offsetLeft = 0
        if params.player == 1 {
            offsetLeft = params.cellSize * (params.columnCount + 1)
        }
        
        self.grid = Grid(
            rowCount: params.rowCount,
            columnCount: params.columnCount,
            extraTopRows: 2,
            cellSize: params.cellSize,
            showCells: settings.debug.showCells,
            showRowColumn: settings.debug.showRowColumnNumbers,
            offsetLeft: offsetLeft
        )
        for (_,cellColumn) in grid.cells {
            for (_, cell) in cellColumn {
                params.scene.addChild(cell.shape)
            }
        }
        params.scene.addChild(self.grid.outline)
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
//                    self.score.calculateMovementPoints()
                    score.movementPoints += 1/7
                    score.totalPoints += 1/7                    
//                    
//                    let movementRemainder = abs(score.movementPoints.truncatingRemainder(dividingBy: 1))
//                    if 1 - movementRemainder < 0.000001 || 1 - movementRemainder > 0.999999{
//                        score.totalPoints += 1
//                    }
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
            var nuisanceBeansToExplode: Set<Cell> = []
            for cell in grid.getCellsWithBeans() {
                cell.mergeAllGroups(grid: grid)
            }
            for cell in grid.getCellsWithBeans() {
                if cell.group.count >= 4 && cell.bean?.color != .gray{
                    for cell in cell.group {
                        cell.group = [cell]
                        self.cellsToExplode.append(cell)
                        
                        let adjacentCells = [
                            cell.getLeftCell(grid: grid),
                            cell.getUpCell(grid: grid),
                            cell.getRightCell(grid: grid),
                            cell.getDownCell(grid: grid)
                        ]
                        for adjacentCell in adjacentCells {
                            let bean = adjacentCell?.bean
                            if bean?.color == .gray {
                                nuisanceBeansToExplode.insert(adjacentCell!)
                            }
                        }
                    }
                }
                cell.group = [cell]
            }
            //merge nuisanceBeansToExplode set into cellsToExplode
            self.cellsToExplodeWithNuisance = cellsToExplode + nuisanceBeansToExplode
            
            if self.cellsToExplodeWithNuisance.count > 0 {
                for cell in self.cellsToExplodeWithNuisance {
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
                        
            for cell in self.cellsToExplodeWithNuisance {
                cell.bean?.shape.removeFromParent()
                cell.bean = nil
            }
            
            //finish popping
            
            self.cellsToExplode = []
            self.cellsToExplodeWithNuisance = []
            self.beans = grid.getBeans()
            setGameState(state: .gravity)
        case .new:
            self.score.sumFullChain()
            self.submitScoreToLeaderboard(score: Int(self.score.numNuisanceBeans))
            
            if score.nuisanceBeansInt > 0 {
                setGameState(state: .dropNuisanceBeans)
                return
            }
            else{
                self.score.reset()
                if self.grid.getStartingCell()!.bean != nil {
                    setGameState(state: .endScreen)
                    return
                }
                generateNewBeans(showNumber: settings.debug.showGroupNumber)
                setGameState(state: .active)
            }

        case .dropNuisanceBeans:
            self.score.reset()
            generateNuisanceBeans(showNumber: settings.debug.showGroupNumber)
            setGameState(state: .gravity)
            
        case .endScreen:
            
            //add menu rectangle
            if self.gameOver == false {
                let endMenuWidth = self.grid.cellSize * 5
                let endMenuHeight = self.grid.cellSize * 6
                let emptyRectangle = SKShapeNode(rectOf: CGSize(
                    width: endMenuWidth,
                    height: endMenuHeight
                ))
                emptyRectangle.fillColor = SKColor.systemPink
                emptyRectangle.strokeColor = SKColor.black
                emptyRectangle.lineWidth = 4
                emptyRectangle.name = "end menu"
                
                // Set its position to the starting cell's position
                emptyRectangle.position = CGPoint(x: 0, y: 0)
                emptyRectangle.zPosition = 4
                // Add the rectangle node to the scene
                self.scene.addChild(emptyRectangle)
                
                //add top text
                let topLabelNode = SKLabelNode(text: "You Suck!! Try again?")
                topLabelNode.position = CGPoint(x: 0, y: 5 * endMenuHeight / 12)
                topLabelNode.fontColor = .black
                topLabelNode.fontSize = 30
                topLabelNode.fontName = "ChalkboardSE-Bold"
                topLabelNode.horizontalAlignmentMode = .center
                topLabelNode.verticalAlignmentMode = .center
                topLabelNode.zPosition = 5
                emptyRectangle.addChild(topLabelNode)
                
                //add image
                let texture = SKTexture(imageNamed: "sadBean")
                // Create an SKSpriteNode using the texture
                let sprite = SKSpriteNode(texture: texture)
                sprite.setScale(0.5)
                // Set position, scale, etc. for the sprite node
                sprite.position = CGPoint(x: 0, y: 0)
                sprite.zPosition = 5
                
                // Add the sprite node to the scene
                emptyRectangle.addChild(sprite)
                
                
                let button = SKShapeNode(rectOf: CGSize(
                    width: 150,
                    height: 50
                ))
                button.position = CGPoint(x: 0, y: -5 * endMenuHeight / 12)
                button.fillColor = SKColor.white
                button.strokeColor = SKColor.black
                button.lineWidth = 4
                button.name = "New Game"
                
                let labelNode = SKLabelNode()
                labelNode.text = "New Game"
                labelNode.name = "New Game"
                labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
                labelNode.zPosition = 6
                button.zPosition = 5
                labelNode.fontColor = .black
                labelNode.fontSize = 25
                labelNode.fontName = "ChalkboardSE-Bold"
                labelNode.horizontalAlignmentMode = .center // Center horizontally
                labelNode.verticalAlignmentMode = .center // Center vertically
                button.addChild(labelNode) // Add label as child of shape node
                emptyRectangle.addChild(button)
            }
            
            self.gameOver = true
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
            startingPosition: grid.getStartingCell()!.getUpCell(grid: grid)!.shape.position,
            showNumber: showNumber
        )
        self.scene.addChild(sideBean.shape)
        
        self.beanPod = BeanPod(activeBean: mainBean, sideBean: sideBean)

    }
    
//    func s
    func generateNuisanceBeans(showNumber: Bool) {
        let numRocks = score.nuisanceBeansInt
        
//        let numChunks = numRocks / grid.columnCount + (numRocks % grid.columnCount > 0 ? 1 : 0)
        var isNextChunkReady = false
        if numRocks > 0 {
            var chosenColumns: Set<Int> = []
            while chosenColumns.count < numRocks{
                let randomColumn = Int.random(in: 0..<grid.columnCount)
                chosenColumns.insert(randomColumn)
            }
            for column in chosenColumns{
                let chosenCell = grid.cells[column]![grid.rowCount]
                let rock = Bean(
                    color: .gray,
                    cellSize: grid.cellSize,
                    startingPosition: chosenCell!.shape.position,
                    showNumber: showNumber
                )
                // Add the nuisance bean to the grid
                chosenCell!.bean = rock
                self.scene.addChild(rock.shape)
                
//                self.beans.append(rock)
            }
            self.beans = self.grid.getBeans()

        }
    }
    
    func loadLeaderboard() async {
        let leaderboards = try! await GKLeaderboard.loadLeaderboards(IDs: ["BestCombo"])
        
        let allPlayers = try! await leaderboards.first?.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...5))
        
        var text: String = ""
                for x in allPlayers!.1 {
                    text += "\(x.player.alias): \(x.score)\n"
                }
        self.score.highScores.text = text
    }
    
    func submitScoreToLeaderboard(score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            
            GKLeaderboard.loadLeaderboards(IDs:["BestCombo"]) { (fetchedLBs, error) in
                guard let lb = fetchedLBs?.first else { return }
                guard let endDate = lb.startDate?.addingTimeInterval(lb.duration), endDate > Date() else { return }
                lb.submitScore(score, context: 0, player: GKLocalPlayer.local) { error in
                }
            }
        }
    }
    

    
#if os(iOS) || os(tvOS)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            initialTouch = touch.location(in: self.scene.view)
            moveAmtX = 0
            moveAmtY = 0
        }
    }
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let movingPoint: CGPoint = t.location(in: self.scene.view)
            
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
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch? {
            self.fastMovement = false
            if moveAmtX == 0 {
                self.beanPod.spinPod(grid: self.grid, clockWise: true)
            }
        }
    }
    
    
#endif
    
#if os(OSX)
    func keyUp(event: NSEvent) {
        //      1 is S
        if event.keyCode == self.controller.down {
            self.fastMovement = false
        }
    }
    
    func keyDown(event: NSEvent) {
        switch event.keyCode {
        case self.controller.right:
            beanPod.moveRight(grid: grid)
        case self.controller.left:
            beanPod.moveLeft(grid: grid)
        case self.controller.down:
            if beanPod.active {
                self.fastMovement = true
            }
        case self.controller.spinClockwise:
            self.beanPod.spinPod(grid: self.grid, clockWise: true)
        case self.controller.spinCounter:
            self.beanPod.spinPod(grid: self.grid, clockWise: false)
        default:
            break
        }
    }
#endif
}
