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
    var colorBonusMap: [Int: Int] = [
        0:0,
        1:0,
        2:3,
        3:6,
        4:12
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
        10: 999
    ]
    var totalPoints = 0
    var movementPoints = 0.0
    var numNuisanceBeans = 0
//    var scoreBoard: Int = 0 {
//        didSet {
//            scoreLabel.text = "Score: \(totalPoints)"
//        }
//    }
    
    init(){
        
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
        let chainPower = self.chainPowerMap[self.chainCount]
        
        
        //calculate bonus points
        var bonusPoints = chainPower! + colorBonus! + groupBonus
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
        
        
        self.numNuisanceBeans = fullComboPoints / 70
    }
    
    func reset() {
        self.chainCount = 0
        self.fullComboPoints = 0
    }
    
    func getGroupBonus(count: Int) -> Int {
        if count > 11 {
            return 10
        }
        
        return groupBonusMap[count]!
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
    
    
