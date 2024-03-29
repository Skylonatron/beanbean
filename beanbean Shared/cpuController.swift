//
//  cpuController.swift
//  beanbean
//
//  Created by Sam Willenson on 3/28/24.
//

import SpriteKit

class cpuController {
    func getNextMove(grid: Grid, beanPod: BeanPod) -> (Bool, Bool) {
        // Implement logic to determine the next move for the AI
        // Example: Randomly choose whether to move left or right
        let moveLeft = Bool.random()
        let clockwiseRotation = Bool.random()
        return (moveLeft, clockwiseRotation)
    }
    
    func applyMove(grid: Grid, beanPod: BeanPod){
        let (moveLeft, clockwiseRotation) = self.getNextMove(grid: grid, beanPod: beanPod)
        if moveLeft {
            beanPod.moveLeft(grid: grid)
        } else {
            beanPod.moveRight(grid: grid)
        }
        
        if clockwiseRotation {
            beanPod.spinPod(grid: grid, clockWise: true)
        }
        else{
            beanPod.spinPod(grid: grid, clockWise: false)
        }
    }
}
