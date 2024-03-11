//
//  Bean.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Bean: Equatable {
    var shape: SKShapeNode
    var active: Bool
    var group: [Bean]
    var labelNode: SKLabelNode
    var cell: Cell?
    
    init(color: SKColor, cellSize: Int, startingPosition: CGPoint) {
        self.active = true
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

        
        self.group = []
        self.group.append(self)

        
        labelNode.text = "\(self.group.count)"
        labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        labelNode.fontColor = .black
        labelNode.fontSize = 40
        labelNode.fontName = "Helvetica-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        self.shape.addChild(self.labelNode) // Add label as child of shape node
        
    }
    
    static func == (lhs: Bean, rhs: Bean) -> Bool {
        return lhs.cell?.column == rhs.cell?.column && lhs.cell?.row == rhs.cell?.row
    }
    

    
}


