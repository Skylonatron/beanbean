//
//  Game.swift
//  beanbean
//
//  Created by Skylar Jones on 3/22/24.
//

import SpriteKit
import GameKit
import AVFoundation

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
    let otherPlayerGame: Game?
    let samBot: samBot
    let seed: UInt64
    let gameMode: GameMode!
    let match: GKMatch?
}

var onlineOtherPlayCells: [String: [String: [String: String]]] = [:]
var pNuisanceBeans: String = ""

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
    var gameLost: Bool = false
    var gameOver: Bool = false
    var otherPlayerGame: Game?
    var samBot: samBot
    var useCPUControls: Bool = false
    var primedNuisanceBeans: Int = 0
    var maxNuisanceSend: Int = 36
    var newBeanBeforeMoreNuisance: Bool = false
    var random: GKRandom
    var backgroundNode: SKSpriteNode?
    var sounds: Sounds!
    var gameMode: GameMode!
    var player: Int?
    var endScreenGenerated: Bool = false
    var totalGamesWon: Int = 0
    let match: GKMatch?
    var nextBeanPod: BeanPod?
    
//  might need to change these speeds to int
    var defaultVerticalSpeed: Int!
    var fastVerticalSpeed: Int!
    var gravitySpeed: Int!
    
    
    // ios movement
    var initialTouch: CGPoint = CGPoint.zero
    var moveAmtX: CGFloat = 0
    var moveAmtY: CGFloat = 0
        
    init(params: GameParams){
        self.scene = params.scene
        self.bounds = params.bounds
        self.sounds = Sounds()
        self.gameMode = params.gameMode
        self.player = params.player
        var cellSize = params.cellSize
//        let music = Music()
        
        self.match = params.match
        self.match?.delegate = self.match

        self.controller = params.controller
        // these numbers should be the number of different colors we are using to randomize from
        // we should check the distribution of these numbers generated
        self.random = GKRandomDistribution(
            randomSource: GKMersenneTwisterRandomSource(seed: params.seed),
            lowestValue: 0,
            highestValue: 3
        )
        
        
        self.otherPlayerGame = params.otherPlayerGame
//        self.player = params.player
        self.samBot = params.samBot
        
        Task {
            await loadLeaderboard()
        }
        
        var offsetLeft = 0
    
        #if os(OSX)
            offsetLeft = params.cellSize * (params.columnCount + 1) + params.cellSize / 4
        #endif
        #if os(iOS) || os(tvOS)
        cellSize = Int(bounds.size.width / 9)
        offsetLeft = Int(Double(cellSize))
//            offsetLeft = cellSize * (params.columnCount + 1) + cellSize / 4
        #endif
        if params.player == 2 {
            #if os(iOS) || os(tvOS)
            cellSize = Int(bounds.size.width / 35)
            offsetLeft = -Int(Double(cellSize) * 13)
            #endif
        }
        
        self.grid = Grid(
            rowCount: params.rowCount,
            columnCount: params.columnCount,
            extraTopRows: 6,
            cellSize: cellSize,
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
        
        self.score = Score(bounds: params.bounds, scene: params.scene, grid: self.grid)
//        self.scene.addChild(score.scoreOutline)
//        self.scene.addChild(score.highScoreOutline)
        addBackground()
        
        if params.player != 1 {
            print("play background music")
            playBackgroundMusic()
        }

    }
    
    func addBackground() {
            // Remove existing background if any
            backgroundNode?.removeFromParent()
            
            // Create a new background node
            let backgroundSize = self.grid.outline.frame.size
            let backgroundTexture = SKTexture(imageNamed: "beanBackground")
            backgroundNode = SKSpriteNode(texture: backgroundTexture, size: backgroundSize)
            backgroundNode?.position = grid.outline.position
            backgroundNode?.zPosition = 0 // Ensure it's behind other nodes
            backgroundNode?.xScale = 0.96
            backgroundNode?.yScale = 0.985
            scene.addChild(backgroundNode!)
        }

    
    func update() {
        if self.player == 2 && self.gameMode == .onlineMultiplayer {
            for column in 0...self.grid.columnCount {
                for row in 0...self.grid.rowCount {
                    let onlineGameCell = onlineOtherPlayCells[String(column)]?[String(row)]
                    let inGameCell = self.grid.cells[column]?[row]
                    
                    if inGameCell?.bean != nil && onlineGameCell == nil {
                        inGameCell?.bean?.shape.removeFromParent()
                        inGameCell?.bean = nil
                        continue
                    }
                    if inGameCell?.bean == nil && onlineGameCell != nil {
                        let bean = Bean(
                            color: getColorFromString(color: onlineGameCell!["color"]!),
                            cellSize: self.grid.cellSize,
                            startingPosition: inGameCell!.shape.position,
                            showNumber: false
                        )
                        inGameCell?.bean = bean
                        scene.addChild(bean.shape)
                        continue
                    }
                    
                }
            }
       
            
            
            return
        }
        if pNuisanceBeans != "" {
            self.primedNuisanceBeans += Int(pNuisanceBeans)!
            pNuisanceBeans = ""
        }
        
        switch gameState {
        case .active:
            
            //handle cpu controls

            if useCPUControls {
                samBot.applyMove(grid: grid, beanPod: beanPod, game: self)
            }
            if self.gameOver == true{
                self.setGameState(state: .endScreen)
            }
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
//                print("got here")
                beanPod.moveDown(speed: self.movementSpeed)
//                print("also here")
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
            
            sounds.playPopSound(chainCount: self.score.chainCount)
            
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
            sendGameData()
            self.score.sumFullChain()
            self.submitScoreToLeaderboard(score: Int(self.score.numNuisanceBeans))
            otherPlayerGame?.primedNuisanceBeans += self.score.nuisanceBeansInt
            if self.score.nuisanceBeansInt > 30 {
                self.sounds.playRedRockSound()
            }
            sendGameDataRocks(rocksToSendInt: self.score.nuisanceBeansInt)
            self.score.resetCombos()
            
            if self.grid.getEndGameCell()!.bean != nil {
                self.gameLost = true
                self.gameOver = true
                self.otherPlayerGame?.gameOver = true
                setGameState(state: .endScreen)
                return
            }
            if self.primedNuisanceBeans > 0 && self.otherPlayerGame != nil && !self.newBeanBeforeMoreNuisance{
                setGameState(state: .dropNuisanceBeans)
                return
            }
            else{
                self.newBeanBeforeMoreNuisance = false
                generateNewBeans(showNumber: settings.debug.showGroupNumber)
//                print("generated new beans")
                setGameState(state: .active)
            }

        case .dropNuisanceBeans:
            generateNuisanceBeans(showNumber: settings.debug.showGroupNumber)
            setGameState(state: .gravity)
            
        case .endScreen:
//            print("self: ", self.totalGamesWon, "other player: ", self.otherPlayerGame?.totalGamesWon)
            if self.player != 2 {
                if self.endScreenGenerated == false {
                    //add menu rectangle
                    let endMenuWidth = self.grid.cellSize * 5
                    let endMenuHeight = self.grid.cellSize * 8
                    let emptyRectangle = SKShapeNode(rectOf: CGSize(
                        width: endMenuWidth,
                        height: endMenuHeight
                    ))
                    emptyRectangle.fillColor = SKColor.systemPink
                    emptyRectangle.strokeColor = SKColor.black
                    emptyRectangle.lineWidth = 4
                    emptyRectangle.name = "end menu"
                    
                    // Set its position to the starting cell's position
                    emptyRectangle.position = self.grid.outline.position
                    emptyRectangle.zPosition = 4
                    // Add the rectangle node to the scene
                    self.scene.addChild(emptyRectangle)
                    
                    //add top text
                    if self.gameLost == true {
                        let topLabelNode = SKLabelNode(text: "You Suck!! Try again?")
                        topLabelNode.position = CGPoint(x: 0, y: 5 * endMenuHeight / 12)
                        topLabelNode.fontColor = .black
                        topLabelNode.fontSize = 20
                        topLabelNode.fontName = "ChalkboardSE-Bold"
                        topLabelNode.horizontalAlignmentMode = .center
                        topLabelNode.verticalAlignmentMode = .center
                        topLabelNode.zPosition = 5
                        emptyRectangle.addChild(topLabelNode)
                    }
                    else {
                        let topLabelNode = SKLabelNode(text: "You Rock!! Try again?")
                        topLabelNode.position = CGPoint(x: 0, y: 5 * endMenuHeight / 12)
                        topLabelNode.fontColor = .black
                        topLabelNode.fontSize = 20
                        topLabelNode.fontName = "ChalkboardSE-Bold"
                        topLabelNode.horizontalAlignmentMode = .center
                        topLabelNode.verticalAlignmentMode = .center
                        topLabelNode.zPosition = 5
                        emptyRectangle.addChild(topLabelNode)
                    }
                    

                    
                    //add image
                    let texture = SKTexture(imageNamed: "sadBean")
                    // Create an SKSpriteNode using the texture
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.setScale(Double(self.grid.cellSize) / 140)
//                    print(self.grid.cellSize)
//                    print(self.bounds.width)
                    // Set position, scale, etc. for the sprite node
                    sprite.position = CGPoint(x: 0, y: endMenuHeight / 12)
                    sprite.zPosition = 4
                    
                    // Add the sprite node to the scene
                    emptyRectangle.addChild(sprite)
                    
                    
                    let newGameButton = SKShapeNode(rectOf: CGSize(
                        width: 160,
                        height: 25
                    ))
                    newGameButton.position = CGPoint(x: 0, y: -5 * endMenuHeight / 12)
                    newGameButton.fillColor = SKColor.white
                    newGameButton.strokeColor = SKColor.black
                    newGameButton.lineWidth = 4
                    newGameButton.name = "New Game"
                    
                    let newGameLabelNode = SKLabelNode()
                    newGameLabelNode.text = "New Game"
                    newGameLabelNode.name = "New Game"
                    newGameLabelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
                    newGameLabelNode.zPosition = 6
                    newGameButton.zPosition = 5
                    newGameLabelNode.fontColor = .black
                    newGameLabelNode.fontSize = 25
                    newGameLabelNode.fontName = "ChalkboardSE-Bold"
                    newGameLabelNode.horizontalAlignmentMode = .center // Center horizontally
                    newGameLabelNode.verticalAlignmentMode = .center // Center vertically
                    newGameButton.addChild(newGameLabelNode) // Add label as child of shape node
                    emptyRectangle.addChild(newGameButton)
                    
                    let leaderboardButton = SKShapeNode(rectOf: CGSize(
                        width: 160,
                        height: 25
                    ))
                    leaderboardButton.position = CGPoint(x: 0, y: Double(-3.5) * Double(endMenuHeight / 12))
                    leaderboardButton.fillColor = SKColor.white
                    leaderboardButton.strokeColor = SKColor.black
                    leaderboardButton.lineWidth = 4
                    leaderboardButton.name = "Leaderboard"
                    
                    let leaderboardLabelNode = SKLabelNode()
                    leaderboardLabelNode.text = "Leaderboard"
                    leaderboardLabelNode.name = "Leaderboard"
                    leaderboardLabelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
                    leaderboardLabelNode.zPosition = 6
                    leaderboardButton.zPosition = 5
                    leaderboardLabelNode.fontColor = .black
                    leaderboardLabelNode.fontSize = 25
                    leaderboardLabelNode.fontName = "ChalkboardSE-Bold"
                    leaderboardLabelNode.horizontalAlignmentMode = .center // Center horizontally
                    leaderboardLabelNode.verticalAlignmentMode = .center // Center vertically
                    leaderboardButton.addChild(leaderboardLabelNode) // Add label as child of shape node
                    emptyRectangle.addChild(leaderboardButton)
                    
                    self.endScreenGenerated = true
                }
            }
            
        }
        score.updateChainCountLabel()
    }
    
    func setGameState(state: GameState) {
        if settings.debug.printGameState {
            print("Setting state to \(state)")
        }
        gameState = state
    }
    
    func generateNewBeans(showNumber: Bool){
        //reset flag for samBot rotation
        self.samBot.hasPerformedRotation = false
        let colors = [SKColor.purple, SKColor.green, SKColor.red, SKColor.yellow]
        
        if self.nextBeanPod == nil {
            self.beanPod = BeanPod(
                activeBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: grid.getStartingCell()!.shape.position,
                    showNumber: showNumber
                ),
                sideBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: grid.getStartingCell()!.getUpCell(grid: grid)!.shape.position,
                    showNumber: showNumber
                )
            )
            self.scene.addChild(self.beanPod.mainBean.shape)
            self.scene.addChild(self.beanPod.sideBean.shape)
            
            self.nextBeanPod = BeanPod(
                activeBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: CGPoint(x: Int(bounds.size.width / 2.7), y: Int(bounds.size.width / 2)),
                    showNumber: showNumber
                ),
                sideBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: CGPoint(x: Int(bounds.size.width / 2.7), y: Int(bounds.size.width / 2) + grid.cellSize),
                    showNumber: showNumber
                )
            )
            
            if self.player != 2 {
                self.scene.addChild(self.nextBeanPod!.mainBean.shape)
                self.scene.addChild(self.nextBeanPod!.sideBean.shape)
            }
        } else {
            self.beanPod = BeanPod(
                activeBean: Bean(
                    color: self.nextBeanPod!.mainBean.color,
                    cellSize: grid.cellSize,
                    startingPosition: grid.getStartingCell()!.shape.position,
                    showNumber: showNumber
                ),
                sideBean: Bean(
                    color:  self.nextBeanPod!.sideBean.color,
                    cellSize: grid.cellSize,
                    startingPosition: grid.getStartingCell()!.getUpCell(grid: grid)!.shape.position,
                    showNumber: showNumber
                )
            )
            
            self.nextBeanPod!.mainBean.shape.removeFromParent()
            self.nextBeanPod!.sideBean.shape.removeFromParent()
            
            self.nextBeanPod = BeanPod(
                activeBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: CGPoint(x: Int(bounds.size.width / 2.7), y: Int(bounds.size.width / 2)),
                    showNumber: showNumber
                ),
                sideBean: Bean(
                    color: colors[random.nextInt()],
                    cellSize: grid.cellSize,
                    startingPosition: CGPoint(x: Int(bounds.size.width / 2.7), y: Int(bounds.size.width / 2) + grid.cellSize),
                    showNumber: showNumber
                )
            )
            
            if self.player != 2 {
                self.scene.addChild(self.nextBeanPod!.mainBean.shape)
                self.scene.addChild(self.nextBeanPod!.sideBean.shape)
            }
            
            
            self.scene.addChild(self.beanPod.mainBean.shape)
            self.scene.addChild(self.beanPod.sideBean.shape)
        }
        

    }
    
    func generateNuisanceBeans(showNumber: Bool) {
        var rocksToSendNow = self.primedNuisanceBeans
        if self.primedNuisanceBeans > self.maxNuisanceSend {
            rocksToSendNow = self.maxNuisanceSend
        }
        self.primedNuisanceBeans -= rocksToSendNow
                
        let result = rocksToSendNow.quotientAndRemainder(dividingBy: self.grid.columnCount + 1)
        
        var findEmptyCellsForNuisance: [Int: Int] = [
            0:0,
            1:0,
            2:0,
            3:0,
            4:0,
            5:0
        ]
//        var numNuisancePossible: Int = 0
//        for row in (0..<Int(self.maxNuisanceSend / (self.grid.columnCount + 1)){
        for row in (0...5){
            for column in (0...self.grid.columnCount){
                let currentCell = self.grid.cells[column]![self.grid.rowCount - row]
                if currentCell?.bean == nil{
                    findEmptyCellsForNuisance[column]! += 1
                }
            }
        }
        
        for row in (0..<result.quotient) {
            for column in (0...self.grid.columnCount) {
                let numNuisancePossible = findEmptyCellsForNuisance[column]
                if numNuisancePossible != 0{
                    findEmptyCellsForNuisance[column]! -= 1
                }
                else{
                    self.primedNuisanceBeans += 1
                    continue
                }
                
                let chosenCell = self.grid.cells[column]![self.grid.rowCount + row + 1]
                let rock = Bean(
                    color: .gray,
                    cellSize: self.grid.cellSize,
                    startingPosition: chosenCell!.shape.position,
                    showNumber: showNumber
                )
                chosenCell!.bean = rock
                self.scene.addChild(rock.shape)
            }
        }
        // drop the last beans randomly
        var allSpots = Array(0...self.grid.columnCount)
        allSpots.shuffle()
        for column in allSpots.prefix(result.remainder) {
            var numNuisancePossible = findEmptyCellsForNuisance[column]
            if numNuisancePossible != 0{
                findEmptyCellsForNuisance[column]! -= 1
            }
            else{
                self.primedNuisanceBeans += 1
                continue
            }
            let chosenCell = self.grid.cells[column]![self.grid.rowCount + result.quotient + 1]
            let rock = Bean(
                color: .gray,
                cellSize: self.grid.cellSize,
                startingPosition: chosenCell!.shape.position,
                showNumber: showNumber
            )
            chosenCell!.bean = rock
            self.scene.addChild(rock.shape)
        }
        self.newBeanBeforeMoreNuisance = true
            
        print("end of dropping")
        self.beans = self.grid.getBeans()
    }
    
    func sendGameDataRocks(rocksToSendInt: Int) {
        guard let match = self.match else {
            return
        }
        
        if let dataToSend = String(rocksToSendInt).data(using: .utf8) {
            do {
                try match.sendData(toAllPlayers: dataToSend, with: .reliable)
            } catch {
                print("Failed to send data: \(error.localizedDescription)")
            }
        } else {
            print("Failed to convert string to data")
        }
    }
    
    func sendGameData() {
        guard let match = self.match else {
            return
        }

//        let jsonData = try! JSONSerialization.data(withJSONObject: self.grid.cells, options: [])
//        let stringToSend = "randomString"
        var jsonData: Data!
        do {
            do {
                jsonData = try JSONSerialization.data(withJSONObject: self.grid.getCellsJSON(), options: [])
            } catch {
                print("Error converting dictionary to JSON string: \(error)")
            }
            try match.sendData(toAllPlayers: jsonData, with: .reliable)
        } catch {
            print("Failed to send game data:", error)
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
    func showLeaderboard() {
        let endMenuWidth = self.grid.cellSize * 5
        let endMenuHeight = self.grid.cellSize * 8
        let extraRectangle = SKShapeNode(rectOf: CGSize(
            width: endMenuWidth,
            height: endMenuHeight
        ))
        extraRectangle.fillColor = SKColor.systemPink
        extraRectangle.strokeColor = SKColor.black
        extraRectangle.lineWidth = 4
        extraRectangle.name = "leaderboardMenu"
        
        // Set its position to the starting cell's position
        extraRectangle.position = self.grid.outline.position
        extraRectangle.zPosition = 20
        // Add the rectangle node to the scene
        self.scene.addChild(extraRectangle)
        extraRectangle.addChild(score.highScoreOutline)
        
        let backButton = SKShapeNode(rectOf: CGSize(
            width: 160,
            height: 25
        ))
        backButton.position = CGPoint(x: 0, y: -5 * endMenuHeight / 12)
        backButton.fillColor = SKColor.white
        backButton.strokeColor = SKColor.black
        backButton.lineWidth = 4
        backButton.name = "Back"
        
        let backLabelNode = SKLabelNode()
        backLabelNode.text = "Back"
        backLabelNode.name = "Back"
        backLabelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        backLabelNode.zPosition = 20
        backButton.zPosition = 20
        backLabelNode.fontColor = .black
        backLabelNode.fontSize = 25
        backLabelNode.fontName = "ChalkboardSE-Bold"
        backLabelNode.horizontalAlignmentMode = .center // Center horizontally
        backLabelNode.verticalAlignmentMode = .center // Center vertically
        backButton.addChild(backLabelNode) // Add label as child of shape node
        extraRectangle.addChild(backButton)
        
    }
    func startNewGame() {
//        self.scene.removeAllChildren()
        for column in grid.cells.values {
            for cell in column.values {
                cell.bean?.shape.removeFromParent()
                cell.bean = nil
            }
        }
        self.beanPod.mainBean.shape.removeFromParent()
        self.beanPod.sideBean.shape.removeFromParent()
        self.nextBeanPod!.mainBean.shape.removeFromParent()
        self.nextBeanPod!.sideBean.shape.removeFromParent()
        self.nextBeanPod = nil
        beans.removeAll()
        
        self.score.resetScoreForNewGame()
        if self.gameLost == false {
            self.totalGamesWon += 1
        }
        self.primedNuisanceBeans = 0
        
        // Remove the end screen
        if let endMenu = self.scene.childNode(withName: "end menu") {
            endMenu.removeFromParent()
        }
        
        self.gameOver = false
        self.endScreenGenerated = false
//        self.otherPlayerGame?.gameOver = false
        
//        generateNewBeans(showNumber: settings.debug.showGroupNumber)
        self.setGameState(state: .new)
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
            if !useCPUControls {
                beanPod.moveRight(grid: grid)
            }
        case self.controller.left:
            if !useCPUControls{
                beanPod.moveLeft(grid: grid)
            }
        case self.controller.down:
            if !useCPUControls{
                if beanPod.active {
                    self.fastMovement = true
                }
            }
        case self.controller.spinClockwise:
            if !useCPUControls{
                self.beanPod.spinPod(grid: self.grid, clockWise: true)
            }
        case self.controller.spinCounter:
            if !useCPUControls{
                self.beanPod.spinPod(grid: self.grid, clockWise: false)
            }
        default:
            break
        }
    }
#endif
}
