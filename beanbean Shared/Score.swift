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
    var chainCount: Int = 0
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
    var totalPoints = 0 {
        didSet {
            scoreLabel.text = "Score: \(totalPoints)"
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
    
    var scoreLabel: SKLabelNode!
    var nuisanceLabel: SKLabelNode!
    
    init(bounds: CGRect){
        // Initialize the score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 42
        scoreLabel.fontColor = .green
        
        // Initialize the nuisance label
        nuisanceLabel = SKLabelNode(text: "Beans Sent: 0")
        nuisanceLabel.position = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2 - 50)
        nuisanceLabel.fontName = "Arial"
        nuisanceLabel.fontSize = 42
        nuisanceLabel.fontColor = .green
        
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
        self.totalPoints += (beanPoints * bonusPoints)
        self.fullComboPoints += (beanPoints * bonusPoints)
        
//        print("color count", colorBonusSet.count)
//        print("color bonus", colorBonus)
//        print("group bonus", groupBonus)
//        print("chain power", chainPower)
//        print("chain count", chainCount)
        
        
    }
    
    func sumFullChain()  {
        

    //  Score = (10 * BP) * (CP + CB + GB)
        
        var movementPointsInt = Int(self.movementPoints)
        self.fullComboPoints += movementPointsInt
        self.numNuisanceBeans = Double(self.fullComboPoints) / 70
        
        self.nuisanceBeansLeftovers += self.numNuisanceBeans.truncatingRemainder(dividingBy: 1)
        
//        print(self.nuisanceBeansLeftovers)
        if self.nuisanceBeansLeftovers > 1 {
            self.nuisanceBeansLeftovers -= 1
            self.numNuisanceBeans += 1
        }
        self.nuisanceBeansInt = Int(numNuisanceBeans)
            
//        print("leftovers", self.nuisanceBeansLeftovers)
//        print("double", self.numNuisanceBeans)
//        print("int", self.nuisanceBeansInt)
        
    }
    
    func reset() {
        self.chainCount = 0
        self.fullComboPoints = 0
        self.movementPoints = 0.0
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
        
        return colorBonusMap[count]!
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
    
    
