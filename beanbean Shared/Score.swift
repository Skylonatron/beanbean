//
//  Score.swift
//  beanbean
//
//  Created by Skylar Jones on 3/21/24.
//

import SpriteKit

class Score {
    var beanPoints: Int = 0
    var bonusPoints: Int = 0
    var fullComboPoints: Int = 0
    var oldScore: Int = 0
    var colorBonusMap: [Int: Int] = [
        0:0,
        1:0,
        2:3,
        3:6,
        4:12,
        5:24
    ]
    var groupBonusMap: [Int: Int] = [
        0:0,
        4:0,
        5:2,
        6:3,
        7:4,
        8:5,
        9:6,
        10:7,
        11:10
    ]
    
    var chainPowerMap: [Int: Int] = [
        0: 0,
        1: 0,
        2: 8,
        3: 16,
        4: 32,
        5: 64,
        6: 128,
        7: 256,
        8: 512,
        9: 999,
    ]
    var totalPoints: Double = 0 {
        didSet {
            scoreLabel.text = "\(Int(totalPoints))"
        }
    }
    var movementPoints: Double = 0.0
    var numNuisanceBeans: Double = 0.0
    var nuisanceBeansLeftovers:Double = 0.0
    var nuisanceBeansInt:Int = 0{
        didSet {
            nuisanceLabel.text = "Beans Sent: : \(self.nuisanceBeansInt)"
        }
    }
    var chainCountLabel: SKLabelNode!
    var chainCountLabelOutline: SKLabelNode!
    var scene: SKScene?
    var chainCount: Int = 0 {
        didSet {
            updateChainCountLabel()
        }
    }
    
    var scoreLabel: SKLabelNode!
    var nuisanceLabel: SKLabelNode!
    var scoreOutline: SKShapeNode!
    var highScoreOutline: SKShapeNode!
    var highScores: SKLabelNode!
    
    var grid : Grid!
    
    
    init(bounds: CGRect, scene: SKScene, grid: Grid){
        self.scene = scene
        self.grid = grid
        
        // Initialize the score label
        scoreOutline = outline(width: bounds.size.width / 2, height: bounds.size.height / 5, lineWidth: 8)
        scoreOutline.position.x = bounds.size.width / 1.75
        scoreOutline.position.y = bounds.size.height / 1.7
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: grid.outline.position.x, y: grid.outline.position.y - CGFloat(grid.cellSize) * 7.1)
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = bounds.size.height / 20
        scoreLabel.fontColor = .cyan
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .bottom
        scoreLabel.zPosition = 8
        scene.addChild(scoreLabel)
        
        // Initialize the nuisance label
        nuisanceLabel = SKLabelNode(text: "Beans Sent: 0")
        nuisanceLabel.position = CGPoint(x: -scoreOutline.frame.width / 2.2, y: -scoreOutline.frame.height / 4)
        nuisanceLabel.fontName = "Arial"
        nuisanceLabel.fontSize = 42
        nuisanceLabel.fontColor = .black
        nuisanceLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .bottom
        scoreOutline.addChild(nuisanceLabel)
        
        
        highScoreOutline = outline(width: bounds.size.width / 2, height: bounds.size.height, lineWidth: 8)
        highScoreOutline.position.x = bounds.size.width / 1.75
        highScoreOutline.position.y = -bounds.size.height / 8
        
        let highScoreText = SKLabelNode(text: "High Scores")
        highScoreText.fontName = "Arial"
        highScoreText.fontSize = 42
        highScoreText.fontColor = .black
        highScoreText.position = CGPoint(x: 0, y: highScoreOutline.frame.height / 2.5)
        highScoreText.horizontalAlignmentMode = .center
        highScoreOutline.addChild(highScoreText)

        self.highScores = SKLabelNode(text: "Loading...")
        self.highScores .numberOfLines = 5
        self.highScores .lineBreakMode = .byWordWrapping
        self.highScores.fontName = "Arial"
        self.highScores.fontSize = 26
        self.highScores.fontColor = .black
        highScoreOutline.addChild(self.highScores)

    }
    
    func calculateChainStep(cellsToExplode: [Cell]) {
        
        //chain starts at 1
        self.chainCount += 1
        
        // calculate BP (Beans Popped)
        let beansPopped = cellsToExplode.count
        
        
        //calculate CB (Color Bonus)
        var colorBonusSet = Set<SKColor>()
//        var colorBonusArray: [SKColor] = []
        for cell in cellsToExplode {
            colorBonusSet.insert(cell.bean!.color)
        }
        let colorBonus = self.colorBonusMap[colorBonusSet.count]
        
        
        //calculate GB (Group Bonus)
        let groupBonus = getGroupBonus(count: beansPopped)
        
        //calculate Chain Power
        let chainPower = getChainPowerBonus(count: self.chainCount)
        
        //calculate bonus points
        var bonusPoints = chainPower + colorBonus! + groupBonus
        if bonusPoints <= 0 {
            bonusPoints = 1
        }
        
        //calculate bean points
        beanPoints = 10 * beansPopped
        
        //add chain step to total
        self.totalPoints += Double(beanPoints * bonusPoints)
        self.fullComboPoints += (beanPoints * bonusPoints)
        
//        print("color count", colorBonusSet.count)
//        print("color bonus", colorBonus)
//        print("group bonus", groupBonus)
//        print("chain power", chainPower)
//        print("chain count", chainCount)
        
        
    }
    
    func sumFullChain()  {
        
    //  Score = (10 * BP) * (CP + CB + GB)
        if self.fullComboPoints > 0 {
            self.fullComboPoints += Int(self.movementPoints)
            self.movementPoints = 0
        }
        self.numNuisanceBeans = Double(self.fullComboPoints) / 70
        
        self.calculateLeftovers()
        self.nuisanceBeansInt = Int(numNuisanceBeans)
            
        
    }
    
    func resetCombos() {
        self.chainCount = 0
        self.fullComboPoints = 0
//        self.movementPoints = 0.0
    }
    
    func resetScoreForNewGame() {
        self.resetCombos()
        self.totalPoints = 0
    }
    
    func calculateLeftovers() {
        self.nuisanceBeansLeftovers += self.numNuisanceBeans.truncatingRemainder(dividingBy: 1)
        
//        print(self.nuisanceBeansLeftovers)
        if self.nuisanceBeansLeftovers > 1 {
            self.nuisanceBeansLeftovers -= 1
            self.numNuisanceBeans += 1
        }
        //        print("leftovers", self.nuisanceBeansLeftovers)
        //        print("double", self.numNuisanceBeans)
        //        print("int", self.nuisanceBeansInt)
    }
    
    
//    func calculateMovementPoints() {
//        self.movementPoints += 1/7
//        let movementRemainder = abs(self.movementPoints.truncatingRemainder(dividingBy: 1))
//        if 1 - movementRemainder < 0.000001 || 1 - movementRemainder > 0.999999{
//            self.totalPoints += 1
//        }
//    }
    
    func getGroupBonus(count: Int) -> Int {
        if count > 11 {
            return 10
        }
        
        return groupBonusMap[count]!
    }
    
    func getChainPowerBonus(count: Int) -> Int {
        if count > 9 {
            return 999
        }
        
        return chainPowerMap[count]!
    }
    func updateChainCountLabel() {
        if self.chainCount > 0{
            // Initialize the chain count label if it's nil
            if chainCountLabel == nil {
                chainCountLabel = SKLabelNode(text: "\(self.chainCount) chain!")
                chainCountLabel?.position = grid.outline.position // Adjust position if necessary
                chainCountLabel?.fontName = "chalkduster"
                chainCountLabel?.fontSize = 60
                chainCountLabel?.fontColor = .white
                chainCountLabel?.horizontalAlignmentMode = .center
                chainCountLabel?.verticalAlignmentMode = .center
                chainCountLabel?.zPosition = 10

                
                scene?.addChild(chainCountLabel)
            } else {
                // Update the text if the label already exists
                chainCountLabel?.text = "\(self.chainCount) chain!"
            }

            // Cancel any existing fade-out action
            chainCountLabel?.removeAllActions()
            
            // Create a new fade-out action
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let wait = SKAction.wait(forDuration: 0.3) // Adjusted wait duration
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
            
            // Run the actions sequence
            chainCountLabel?.run(sequence) {
                // remove the label from the scene after fading out
            self.chainCountLabel?.removeFromParent()
            self.chainCountLabel = nil
            }
        }
        else{
            return
        }
        
        
    }
    
    //NP = nuisance points
    //SC = current chain score
    //TP = Target points, or score per nuisance puyo. Default is 70.
//    NL = Leftover nuisance points, a decimal between 0 and 1.
//    NC = Number of nuisance puyo to send, rounded down.
    //formula:
//    NP = SC / TP + NL
//    NC = ⌊ NP ⌋
//    NL = NP - NC
    
    
}
    
    
