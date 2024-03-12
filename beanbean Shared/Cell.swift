//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Cell: Equatable{
    var shape: SKShapeNode
    var bean: Bean?
    var column: Int
    var row: Int
    var group: [Cell]
    
    
    init(cellSize: Int, x: CGFloat, y: CGFloat, column: Int, row: Int, show: Bool) {
        self.shape = SKShapeNode(rectOf: CGSize(
            width: cellSize,
            height: cellSize
        ))
        // Set the position of the rectangle
        self.shape.position = CGPoint(x: x, y: y)
        // Set the fill color of the rectangle
        self.shape.fillColor = SKColor.white
        // Set the stroke color of the rectangle
        
        self.column = column
        self.row = row
        if show {
            self.shape.strokeColor = SKColor.black
        }
        
        self.group = []
        self.group.append(self)
    }
    
    
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
    
    func mergeAllGroups(grid: Grid) {
        let upCell = self.getUpCell(grid: grid)
        let downCell = self.getDownCell(grid: grid)
        let rightCell = self.getRightCell(grid: grid)
        let leftCell = self.getLeftCell(grid: grid)
        
        for c in [upCell, downCell, rightCell, leftCell]{
            self.mergeGroups(c: c)
            
        }
    }
    
    func mergeGroups(c: Cell?) {
        if c != nil && c!.bean != nil {
            if c!.bean!.shape.fillColor == self.bean!.shape.fillColor {
                if !c!.group.contains(self) {
                    var newGroup: [Cell] = c!.group
                    newGroup += self.group
                    
                    for c in newGroup{
                        c.group = newGroup
                        c.bean!.labelNode.text = "\(c.group.count)"
                    }
                }
            }
        }
    }
    
    func getLeftCell(grid: Grid) -> Cell? {
        return grid.cells[self.column - 1]?[self.row]
    }
    func getRightCell(grid: Grid) -> Cell? {
        return grid.cells[self.column + 1]?[self.row]
    }
    func getUpCell(grid: Grid) -> Cell? {
        return grid.cells[self.column]?[self.row + 1]
    }
    func getDownCell(grid: Grid) -> Cell? {
        return grid.cells[self.column]?[self.row - 1]
    }
    
}
