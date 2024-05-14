//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Grid {
    var cells: [Int: [Int: Cell]] = [:]
    
    var offsetLeft: CGFloat
    var offsetDown: CGFloat
    var cellSize: Int
    var columnCount: Int
    var rowCount: Int
    var extraTopRows: Int
    var outline: SKShapeNode
    
    init(rowCount: Int, columnCount: Int, extraTopRows: Int, cellSize: Int, showCells: Bool, showRowColumn: Bool, offsetLeft: Int) {
        
        self.outline = SKShapeNode(rectOf: CGSize(
            width: cellSize * (columnCount + 1) + 8,
            height: cellSize * (rowCount + 1) + 4
        ))
        self.outline.strokeColor = .darkGray
        self.outline.lineWidth = 8
        self.outline.position.x = CGFloat(-offsetLeft)
        self.outline.zPosition = 5
        
        self.offsetLeft = CGFloat((columnCount + 1) / 2) * CGFloat(cellSize) - (CGFloat(cellSize) / 2) + CGFloat(offsetLeft)
        self.offsetDown = CGFloat((rowCount + 1) / 2) * CGFloat(cellSize)
        self.cellSize = cellSize
        self.columnCount = columnCount
        self.rowCount = rowCount
        self.extraTopRows = extraTopRows
        
//        self.outline.position.x = -self.offsetLeft
//        self.outline.position.y = -self.offsetDown
                
        for column in 0...columnCount {
            cells[column] = [Int: Cell]()
            for row in 0...rowCount + extraTopRows {
                let cell = Cell(
                    cellSize: cellSize,
                    x: CGFloat(cellSize * column) - self.offsetLeft,
                    y: CGFloat(cellSize * row) - self.offsetDown,
                    column: column,
                    row: row,
                    show: showCells,
                    showRowColumn: showRowColumn,
                    invisibleTopRow: false
                )
                cells[column]![row] = cell
            }
            for row in (rowCount+1)...(rowCount + extraTopRows) {
                let cell = Cell(
                    cellSize: cellSize,
                    x: CGFloat(cellSize * column) - self.offsetLeft,
                    y: CGFloat(cellSize * row) - self.offsetDown,
                    column: column,
                    row: row,
                    show: showCells,
                    showRowColumn: showRowColumn,
                    invisibleTopRow: true
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
    
    func getEndGameCell() -> Cell? {
        return cells[Int(self.columnCount / 2)]![self.rowCount]
    }
    
    func getStartingCell() -> Cell? {
        return cells[Int(self.columnCount / 2)]![self.rowCount + 1]
    }
    
    func getCellsJSON() -> [String: [String: [String: String]]] {
        var myDictionary: [String: [String: [String: String]]] = [:]

        for column in 0...self.columnCount {
            myDictionary[String(column)] = [:]
            for row in 0...self.rowCount {
                if self.cells[column]?[row]?.bean != nil {
                    let b = self.cells[column]?[row]?.bean
                    
                    myDictionary[String(column)]?[String(row)] = [
                        "color" : b!.getColorString()
                    ]
                }
            }
        }
        
        return myDictionary
    }
    
}
