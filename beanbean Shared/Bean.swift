//
//  Bean.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Bean {
    var shape: SKShapeNode
    var labelNode: SKLabelNode
    var beanImage: SKShapeNode
    var checked: Bool
    var markForDelete: Bool = false
    var group: [Bean]
    var color: SKColor

    
    init(color: SKColor, cellSize: Int, startingPosition: CGPoint, showNumber: Bool) {
        self.shape = SKShapeNode(
            rectOf: CGSize(
                width: cellSize,
                height: cellSize
            )
        )
        
        // Set the position of the rectangle
        self.shape.position = startingPosition
        // Set the fill color of the rectangle
        self.shape.fillColor = SKColor.clear
        // Set the stroke color of the rectangle
        self.shape.strokeColor = SKColor.clear
        self.shape.fillColor = color
        self.shape.strokeColor = color
        self.labelNode = SKLabelNode()
        self.checked = false
        
        self.color = color

        self.beanImage = SKShapeNode(circleOfRadius: Double(cellSize) / 8)
        self.beanImage.position = self.shape.position
        self.beanImage.strokeColor = SKColor.black
        self.beanImage.lineWidth = 5
        self.beanImage.fillColor = color
        

        if showNumber {
            labelNode.text = "1"
            labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
            labelNode.fontColor = .black
            labelNode.fontSize = 40
            labelNode.fontName = "Helvetica-Bold"
            labelNode.horizontalAlignmentMode = .center // Center horizontally
            labelNode.verticalAlignmentMode = .center // Center vertically
            self.shape.addChild(self.labelNode) // Add label as child of shape node
        }
        
        self.group = []
        self.group.append(self)
        
    }
    
    func canMoveDown(grid: Grid, speed: Double) -> Bool {
        let futureCell = self.getCellOffsetY(grid: grid, offset: -speed)
        return futureCell != nil && futureCell?.bean == nil
    }
    
    func getCell(grid: Grid) -> Cell! {
        return grid.getCell(x: self.shape.position.x, y: self.shape.position.y)
    }
    
    func getCellOffsetY(grid: Grid, offset: CGFloat) -> Cell! {
        return grid.getCell(x: self.shape.position.x, y: self.shape.position.y + offset)
    }
    
    func getCellOffsetX(grid: Grid, offset: CGFloat) -> Cell! {
        return grid.getCell(x: self.shape.position.x + offset, y: self.shape.position.y)
    }
}


