//
//  BeanPod.swift
//  beanbean
//
//  Created by Skylar Jones on 3/11/24.
//

import SpriteKit

class BeanPod {
    
    var mainBean: Bean
    var sideBean: Bean
    var active: Bool = true
    var elapsedTime: TimeInterval = 0 // handle delay over nil/bean
    
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
//        print("main", leftCellMain)
//        print("side", leftCellSide)
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
    
    func spinPod(grid: Grid, speed: Double, beanPod: BeanPod){
        let mainCell = self.mainBean.getCell(grid: grid)
        let mainBeanX = mainBean.shape.position.x
        let mainBeanY = mainBean.shape.position.y
        let cellSize = CGFloat(grid.cellSize)
        let sideCell = self.sideBean.getCell(grid: grid)
        let rightCell = mainCell?.getRightCell(grid: grid)
        let upCell = mainCell?.getUpCell(grid: grid)
        let leftCell = mainCell?.getLeftCell(grid: grid)
        let downCell = mainCell?.getDownCell(grid: grid)
        
        if sideCell == rightCell {
            if let upCell = upCell {
                if upCell.bean == nil {
                    self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY + cellSize)
                }
            }
        }
        if sideCell == upCell {
            if canMoveLeft(grid: grid) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
            }
            if !canMoveLeft(grid: grid) && canMoveRight(grid: grid){
                print("Main bean X before move: \(self.mainBean.shape.position.x)")
                beanPod.moveRight(grid: grid)
                print("Main bean X after move: \(self.mainBean.shape.position.x)")
                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY)
                self.mainBean.shape.position = CGPoint(x: mainBeanX + cellSize, y: mainBeanY)
            }
            if let leftCell = leftCell, let rightCell = rightCell, leftCell.bean != nil, rightCell.bean == nil{
                self.mainBean.shape.position = (mainCell?.getRightCell(grid: grid)!.shape.position)!
                self.sideBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
            }
            if let leftCell = leftCell, let rightCell = rightCell, leftCell.bean != nil, rightCell.bean == nil{
                self.mainBean.shape.position = (mainCell?.getRightCell(grid: grid)!.shape.position)!
                self.sideBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
            }
            if let leftCell = leftCell, let rightCell = rightCell, leftCell.bean != nil, rightCell.bean == nil{
                self.mainBean.shape.position = (mainCell?.getRightCell(grid: grid)!.shape.position)!
                self.sideBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
            }
        }
        if sideCell == leftCell {
            if let downCell = downCell {
                if downCell.bean == nil {
                    
                    self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY - cellSize)
                }
            }
        }
        if sideCell == downCell {
            if canMoveRight(grid: grid) {
                self.sideBean.shape.position = CGPoint(x: mainBeanX + cellSize, y: mainBeanY)
            }
//            if !canMoveRight(grid: grid) && canMoveLeft(grid: grid){
//                print("Main bean X before move: \(self.mainBean.shape.position.x)")
//                beanPod.moveLeft(grid: grid)
//                print("Main bean X after move: \(self.mainBean.shape.position.x)")
//                self.sideBean.shape.position = CGPoint(x: mainBeanX, y: mainBeanY)
//                self.mainBean.shape.position = CGPoint(x: mainBeanX - cellSize, y: mainBeanY)
//            }
            
        }
        
    }
    
}
    
