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
//    var grid: Grid!
    func samBot(grid: Grid, beanPod: BeanPod) -> (Int) {
        // Implement logic to determine the next move for the AI
        if beanPod.active{
            let mainBeanColor = beanPod.mainBean.color
            let sideBeanColor = beanPod.sideBean.color
            moveLeft = false
            moveRight = false
            for row in (0..<grid.rowCount).reversed(){
                for column in 0..<grid.columnCount{
                    if let cell = grid.cells[column]?[row]{
                        let cellBeanColor = cell.bean?.color
                        let cellXPosition = cell.shape.position.x
                        let upCell = cell.getUpCell(grid: grid)
                        let mainBeanCell = beanPod.mainBean.getCell(grid: grid)
                        let mainBeanXPosition = beanPod.mainBean.shape.position.x
                        let sideBeanXPosition = beanPod.sideBean.shape.position.x
                        if cellBeanColor == mainBeanColor{
                            if upCell?.bean == nil{
//                                moveLeft = cellXPosition < beanPod.mainBean.shape.position.x
//                                moveRight = cellXPosition > beanPod.mainBean.shape.position.x
//                                break
                                let moveDistance = Int(cellXPosition - mainBeanXPosition) / grid.cellSize
                                return moveDistance
                            }
                        }
                        if cellBeanColor == sideBeanColor{
                            if upCell?.bean == nil{
//                                moveLeft = cellXPosition < beanPod.sideBean.shape.position.x
//                                moveRight = cellXPosition > beanPod.sideBean.shape.position.x
//                                break
                                let moveDistance = Int(cellXPosition - sideBeanXPosition) / grid.cellSize
                                return moveDistance
                            }
                        }
//                        print(cell.shape.position)
//                        if cell.bean != nil{
//                            let cellBeanColor = cell.bean?.color
//                            let cellXPosition = cell.shape.position.x
//                            let upCell = cell.getUpCell(grid: grid)
//                            let mainBeanCell = beanPod.mainBean.getCell(grid: grid)
//                            if cellBeanColor == mainBeanColor && upCell?.bean != nil{
//                                moveLeft = cellXPosition < beanPod.mainBean.shape.position.x
//                                break
//                            }
//                            if cellBeanColor == mainBeanColor && upCell?.bean != nil{
//                                moveRight = cellXPosition > beanPod.mainBean.shape.position.x
//                                break
//                            }
//                            if cellBeanColor == sideBeanColor && cellXPosition < beanPod.sideBean.shape.position.x{
//                                moveLeft = true
//                                break
//                            }
//                            if cellBeanColor == sideBeanColor && cellXPosition > beanPod.sideBean.shape.position.x{
//                                moveRight = true
//                                break
//                            }
//                    
//                        }
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
        return (0)
        
    }
    
    func applyMove(grid: Grid, beanPod: BeanPod, game: Game){
        let moveDistance = self.samBot(grid: grid, beanPod: beanPod)
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
        
        
//        if clockwiseRotation {
//            beanPod.spinPod(grid: grid, clockWise: true)
//        }
//        else{
//            beanPod.spinPod(grid: grid, clockWise: false)
//        }
    }

