//
//  BeanPod.swift
//  beanbean
//
//  Created by Skylar Jones on 3/11/24.
//

import SpriteKit

enum Position {
    case right
    case left
    case up
    case down
}

class BeanPod {
    
    var mainBean: Bean
    var sideBean: Bean
    var active: Bool = true
    var elapsedTime: TimeInterval = 0 // handle delay over nil/bean
    var sideBeanPosition: Int = 1

    
    init(activeBean: Bean, sideBean: Bean){
        self.mainBean = activeBean
        self.sideBean = sideBean
    }
    
    func canMoveRight(grid: Grid) -> Bool {
        if !self.active {
            return false
        }
        let rightCellMain =  self.mainBean.getCell(grid: grid).getRightCell(grid: grid)
        let rightCellSide = self.sideBean.getCell(grid: grid).getRightCell(grid: grid)
        
        return rightCellMain != nil && rightCellMain!.bean == nil && rightCellSide != nil && rightCellSide!.bean == nil
    }
    
    func moveRight(grid: Grid) {
        let rightCellMain =  self.mainBean.getCell(grid: grid).getRightCell(grid: grid)
        let rightCellSide = self.sideBean.getCell(grid: grid).getRightCell(grid: grid)
        
        self.mainBean.shape.position.x = rightCellMain!.shape.position.x
        self.sideBean.shape.position.x = rightCellSide!.shape.position.x
    }
    
    func canMoveLeft(grid: Grid) -> Bool {
        if !self.active {
            return false
        }
        let leftCellMain =  self.mainBean.getCell(grid: grid).getLeftCell(grid: grid)
        let leftCellSide = self.sideBean.getCell(grid: grid).getLeftCell(grid: grid)

        return leftCellMain != nil && leftCellMain!.bean == nil && leftCellSide != nil && leftCellSide!.bean == nil
    }
    
    func moveLeft(grid: Grid) {
        let leftCellMain =  self.mainBean.getCell(grid: grid).getLeftCell(grid: grid)
        let leftCellSide = self.sideBean.getCell(grid: grid).getLeftCell(grid: grid)
        
        self.mainBean.shape.position.x = leftCellMain!.shape.position.x
        self.sideBean.shape.position.x = leftCellSide!.shape.position.x
    }
    
    func canMoveDown(grid: Grid, speed: Double) -> Bool {
        let futureCell = self.mainBean.getCellOffsetY(grid: grid, offset: -speed)
        let futureSideCurrentCell = sideBean.getCellOffsetY(grid: grid, offset: -speed)
        
        return futureCell != nil && futureCell?.bean == nil && futureSideCurrentCell != nil && futureSideCurrentCell?.bean == nil
    }
    
    func moveDown(speed: Double) {
        self.mainBean.shape.position.y -= speed
        self.sideBean.shape.position.y -= speed
    }
    
    
    // sets beans position to the position of the cell that it is currently in and returns those cells
    func snapToCell(grid: Grid) -> (Cell, Cell) {
        let mainCell = self.mainBean.getCell(grid: grid)
        let sideCell = self.sideBean.getCell(grid: grid)
        
        self.mainBean.shape.position = mainCell!.shape.position
        self.sideBean.shape.position = sideCell!.shape.position
        
        return (mainCell!, sideCell!)
        
    }
    
    func spinPod(grid: Grid, clockWise: Bool){
        
        let directions = [Position.up, Position.right, Position.down, Position.left]
        var indexIfSpins: Int
        // will get next or previous position in array, if at end of array will move to beginning and vice versa
        if clockWise {
            indexIfSpins = (sideBeanPosition + 1) % directions.count
        } else {
            indexIfSpins = (sideBeanPosition - 1 + directions.count) % directions.count
        }
                
        let mainBeanX = mainBean.shape.position.x
        let mainBeanY = mainBean.shape.position.y
        let cellSize = CGFloat(grid.cellSize)
        //
        switch directions[indexIfSpins] {
        case .up:
            let upCell = self.mainBean.getCell(grid: grid).getUpCell(grid: grid)
            if available(cell: upCell) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY + cellSize)
                self.sideBeanPosition = indexIfSpins
            }
        case .left:
            if !canMoveLeft(grid: grid) && canMoveRight(grid: grid){
                self.moveRight(grid: grid)
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY)
                self.mainBean.shape.position = CGPoint(x: mainBeanX + cellSize, y: mainBeanY)
                self.sideBeanPosition = indexIfSpins
            } else if canMoveLeft(grid: grid) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
                self.sideBeanPosition = indexIfSpins
            }
        case .right:
            if !canMoveRight(grid: grid) && canMoveLeft(grid: grid){
                self.moveLeft(grid: grid)
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY)
                self.mainBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
                self.sideBeanPosition = indexIfSpins
            } else if canMoveRight(grid: grid) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX + cellSize, y: mainBeanY)
                self.sideBeanPosition = indexIfSpins
            }
        case .down:
            let downCell = mainBean.getCell(grid: grid).getDownCell(grid: grid)
            if available(cell: downCell) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY - cellSize)
            } else {
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y:  mainBean.getCell(grid: grid).shape.position.y)
                self.mainBean.shape.position = CGPoint(x: mainBeanX, y:  mainBean.getCell(grid: grid).shape.position.y + cellSize)
            }
            self.sideBeanPosition = indexIfSpins
        }
    }
    
}
    
