//
//  Bean.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Bean {
    var shape: SKShapeNode
    var active: Bool
    
    init(color: SKColor, cellSize: Int) {
        self.active = true
        self.shape = SKShapeNode(
            rectOf: CGSize(
                width: cellSize,
                height: cellSize
            )
        )
        
        // Set the position of the rectangle
        self.shape.position = CGPoint(x: 0, y:0)
        // Set the fill color of the rectangle
        self.shape.fillColor = color
        // Set the stroke color of the rectangle
        self.shape.strokeColor = SKColor.white
    }
    
}


