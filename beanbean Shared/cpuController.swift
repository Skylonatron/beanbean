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
}
