//
//  samBot.swift
//  beanbean
//
//  Created by Sam Willenson on 3/28/24.
//

import SpriteKit

class samBot {
    var moveLeft = false
    var moveRight = false
    var rotateClockwise = true
    var hasPerformedRotation = false
    
    var qLearning: QLearning
    
    init(qLearning: QLearning) {
        self.qLearning = qLearning
    }
    
    func decideMove(action: QLearning.QLearningAction) -> (Int) {
        // Implement logic to determine the next move for the AI
        switch action {
            
        case .moveLeft:
            return -1
            
        case .moveRight:
            return 1
            
        case .rotateClockwise:
            return 0
        
        case .defaultAction:
            return 2
            
        }
        
    }
    
    func applyMove(grid: Grid, beanPod: BeanPod, game: Game, action: QLearning.QLearningAction ){
        if !hasPerformedRotation {
            beanPod.spinPod(grid: grid, clockWise: action == .rotateClockwise)
            hasPerformedRotation = true
            return
        }
        let moveDistance = self.decideMove(action: action)
        if moveDistance != 0{
//            print(moveDistance)
            if moveDistance > 0{
                for _ in 0..<moveDistance {
                    beanPod.moveRight(grid: grid)
                }
            }
            else{
                for _ in 0..<abs(moveDistance){
                    beanPod.moveLeft(grid: grid)
                }
            }
        }
        
        game.fastMovement = true
//        if moveLeft {
//            beanPod.moveLeft(grid: grid)
//        }
//        if moveRight{
//            beanPod.moveRight(grid: grid)
        }
    
    func findGroupsLessThanThree(grid: Grid, beanPod: BeanPod) -> Bool {
        var foundGroups = false
        
        for cell in grid.getCellsWithBeans(){
            if cell.group.count < 3 && cell.bean?.color == beanPod.mainBean.color{
                foundGroups = true
                break
            }
        }
        return foundGroups
    }
        
        
//        if clockwiseRotation {
//            beanPod.spinPod(grid: grid, clockWise: true)
//        }
//        else{
//            beanPod.spinPod(grid: grid, clockWise: false)
//        }
    }

