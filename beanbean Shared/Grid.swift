//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Grid {
    var shape: SKShapeNode
    var cells: [Int: [Int: Cell]] = [:]
    var offsetLeft: CGFloat
    var offsetDown: CGFloat
    var cellSize: Int
    var columnCount: Int
    var rowCount: Int

    
    init(rowCount: Int, columnCount: Int, cellSize: Int, bounds: CGRect, showCells: Bool, showRowColumn: Bool) {
        self.shape = SKShapeNode(rectOf: CGSize(
            width: bounds.width / 1.5,
            height: bounds.height / 1.5
        ))
        
//        self.shape.position = CGPoint(x: bounds.width / x, y: bounds.width / y)
//        self.shape.fillColor = SKColor.black
//        self.shape.strokeColor = SKColor.white
        
        self.offsetLeft = CGFloat((columnCount / 2) * cellSize)
        self.offsetDown = CGFloat((rowCount / 2) * cellSize)
        self.cellSize = cellSize
        self.columnCount = columnCount
        self.rowCount = rowCount
                
        for column in 0...columnCount {
            cells[column] = [Int: Cell]()
            for row in 0...rowCount {
                let cell = Cell(
                    cellSize: cellSize,
                    x: CGFloat(cellSize * column) - self.offsetLeft,
                    y: CGFloat(cellSize * row) - self.offsetDown,
                    column: column,
                    row: row,
                    show: showCells,
                    showRowColumn: showRowColumn
                )
                cells[column]![row] = cell
            }

        }
                    
    }
    
    func getCellsWithBeans() -> [Cell] {
        var allCells = [Cell]()
        for (_,cellColumn) in self.cells {
            for (_, cell) in cellColumn {
                if cell.bean != nil {
                    allCells.append(cell)
                }
            }
        }
        
        return allCells
    }
    
    func getBeans() -> [Bean] {
        var beans = [Bean]()
        for (_,cellColumn) in self.cells {
            for (_, cell) in cellColumn {
                if cell.bean != nil {
                    beans.append(cell.bean!)
                }
            }
        }
        
        return beans
    }
    
    func getCellCord(x: Double, y: Double) -> (Int, Int) {
        let cellY = (y + self.offsetDown) / Double(self.cellSize)
        let cellX = (x + self.offsetLeft) / Double(self.cellSize)
        return (Int(floor(cellX)), Int(floor(cellY)))
    }
    
    func getCell(x: Double, y: Double) -> Cell? {
        let cellCords = getCellCord(x: x, y: y)
        return cells[cellCords.0]?[cellCords.1]
    }
    
    func getStartingCell() -> Cell? {
        return cells[Int(self.columnCount / 2)]![self.rowCount]
    }
    
}
