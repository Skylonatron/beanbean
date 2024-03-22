//
//  Score.swift
//  beanbean
//
//  Created by Skylar Jones on 3/21/24.
//

import SpriteKit

class Score {
    var beansPopped: Int = 0
    var beansPoppedInChain: Int = 0
    var groupBonus: Int = 0
    var chainCount: Int = 0
    var colorBonusArray: [SKColor] = []
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
    var numNuisanceBeans = 0
//    var scoreBoard: Int = 0 {
//        didSet {
//            scoreLabel.text = "Score: \(totalPoints)"
//        }
//    }
    
    init(){
        
    }
    
    func aggregate(cellsToExplode: [Cell]) {
        self.beansPoppedInChain = cellsToExplode.count
        // calculate BP (Beans Popped)
        self.beansPopped += cellsToExplode.count
        
        //calculate CB (Color Bonus)
        for cell in cellsToExplode {
            colorBonusArray.append(cell.bean!.color)
        }
        //calculate GB (Group Bonus)
        self.groupBonus += groupBonusMap[cellsToExplode.count]!
        self.chainCount += 1
    }
    
    func calculateScore()  {
        // remove duplicates
        let colorBonusSet = Set(colorBonusArray)

    //  Score = (10 * BP) * (CP + CB + GB)
        let chainPower = self.chainPowerMap[self.chainCount]
        let colorBonus = self.colorBonusMap[colorBonusSet.count]
        
        let x1 = 10 * self.beansPopped
        var x2 = chainPower! + colorBonus! + self.groupBonus
        if x2 <= 0 {
            x2 = 1
        }
                
        self.totalPoints += (x1 * x2)
        self.numNuisanceBeans = (x1 * x2) / 70
    }
    
    func reset() {
        self.chainCount = 0
        self.groupBonus = 0
        beansPopped = 0
        self.beansPoppedInChain = 0
        colorBonusArray = []
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
    
    
