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
    var checked: Bool
    var markForDelete: Bool = false

    
    init(color: SKColor, cellSize: Int, startingPosition: CGPoint) {
        self.shape = SKShapeNode(
            rectOf: CGSize(
                width: cellSize,
                height: cellSize
            )
        )
        
        // Set the position of the rectangle
        self.shape.position = startingPosition
        // Set the fill color of the rectangle
        self.shape.fillColor = color
        // Set the stroke color of the rectangle
        self.shape.strokeColor = SKColor.white
        self.labelNode = SKLabelNode()
        self.checked = false

        
        labelNode.text = "1"
        labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        labelNode.fontColor = .black
        labelNode.fontSize = 40
        labelNode.fontName = "Helvetica-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        self.shape.addChild(self.labelNode) // Add label as child of shape node
        
    }
    
    func getCell(grid: Grid) -> Cell! {
        return grid.getCell(x: self.shape.position.x, y: self.shape.position.y)
    }
    
    func getCellOffsetY(grid: Grid, offset: CGFloat) -> Cell! {
//        return grid.getCell(x: self.shape.position.x, y: self.shape.position.y)
        return grid.getCell(x: self.shape.position.x, y: self.shape.position.y + offset)
    }
}


