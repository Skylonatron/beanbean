//
//  cpuController.swift
//  beanbean
//
//  Created by Sam Willenson on 3/28/24.
//

import SpriteKit

class cpuController {
    var moveLeft = false
    var moveRight = false
    var rotateClockwise = true
    func samBot(grid: Grid, beanPod: BeanPod) -> (Bool, Bool) {
        // Implement logic to determine the next move for the AI
        if beanPod.active{
            let mainBeanColor = beanPod.mainBean.color
            let sideBeanColor = beanPod.sideBean.color
            moveLeft = false
            moveRight = false
            for row in (0..<grid.rowCount).reversed(){
                for column in 0..<grid.columnCount{
                    if let cell = grid.cells[column]?[row]{
                        print(cell.shape.position)
                        if cell.bean != nil{
                            let cellBeanColor = cell.bean?.color
                            let cellXPosition = cell.shape.position.x
                            if cellBeanColor == mainBeanColor{
                                moveLeft = cellXPosition < beanPod.mainBean.shape.position.x
                                break
                            }
                            if cellBeanColor == mainBeanColor{
                                moveRight = cellXPosition > beanPod.mainBean.shape.position.x
                                break
                            }
                            if cellBeanColor == sideBeanColor && cellXPosition < beanPod.sideBean.shape.position.x{
                                moveLeft = true
                                break
                            }
                            if cellBeanColor == sideBeanColor && cellXPosition > beanPod.sideBean.shape.position.x{
                                moveRight = true
                                break
                            }
                    
                        }
                    }
                    
                    //                if clockwiseRotation {
                    //                    beanPod.spinPod(grid: grid, clockWise: true)
                    //                }
                    //                else{
                    //                    beanPod.spinPod(grid: grid, clockWise: false)
                    //                }
                    
//                    while cellXPosition > beanPod.mainBean.shape.position.x {
//                        beanPod.moveLeft(grid: grid)
                }
                
            }
       
            
        }
        return (moveLeft, rotateClockwise)
        
    }
    
    func applyMove(grid: Grid, beanPod: BeanPod, game: Game){
        let (moveLeft, clockwiseRotation) = self.samBot(grid: grid, beanPod: beanPod)
        if moveLeft {
            beanPod.moveLeft(grid: grid)
        }
        if moveRight{
            beanPod.moveRight(grid: grid)
        }
        game.fastMovement = true
        
//        if clockwiseRotation {
//            beanPod.spinPod(grid: grid, clockWise: true)
//        }
//        else{
//            beanPod.spinPod(grid: grid, clockWise: false)
//        }
    }
}
