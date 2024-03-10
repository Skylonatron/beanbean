//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Cell {
    var shape: SKShapeNode
    var bean: Bean?
    var column: Int
    var row: Int
    
    
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
