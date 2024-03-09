//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Grid {
    var shape: SKShapeNode
    var cells: [String: Cell] = [:]
    var offsetLeft: CGFloat
    var offsetDown: CGFloat
    var cellSize: Int

    
    init(rowCount: Int, columnCount: Int, cellSize: Int, bounds: NSRect, showCells: Bool) {
        self.shape = SKShapeNode(rectOf: CGSize(
            width: bounds.width / 1.5,
            height: bounds.height / 1.5
        ))
        // Set the position of the rectangle
//        self.shape.position = CGPoint(x: bounds.width / x, y: bounds.width / y)
        // Set the fill color of the rectangle
//        self.shape.fillColor = SKColor.black
        // Set the stroke color of the rectangle
//        self.shape.strokeColor = SKColor.white
        
        self.offsetLeft = CGFloat((columnCount / 2) * cellSize)
        self.offsetDown = CGFloat((rowCount / 2) * cellSize)
        self.cellSize = cellSize
        
        for column in 0...columnCount {
            for row in 0...rowCount {
                let cell = Cell(
                    cellSize: cellSize,
                    x: CGFloat(cellSize * column) - self.offsetLeft,
                    y: CGFloat(cellSize * row) - self.offsetDown,
                    show: showCells
                )
                cells["\(row)\(column)"] = cell
            }

        }
                    
    }
    
    func getCellCord(x: Double, y: Double) -> (Int, Int) {
        let cellY = (y + self.offsetDown + Double(self.cellSize / 2)) / Double(self.cellSize)
        let cellX = (x + self.offsetLeft + Double(self.cellSize / 2)) / Double(self.cellSize)
        return (Int(cellX), Int(cellY))
    }
    
}
