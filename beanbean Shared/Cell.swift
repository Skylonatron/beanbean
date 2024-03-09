//
//  Grid.swift
//  beanbean
//
//  Created by Skylar Jones on 3/8/24.
//

import SpriteKit

class Cell {
    var shape: SKShapeNode
    
    
    init(cellSize: Int, x: CGFloat, y: CGFloat, show: Bool) {
        self.shape = SKShapeNode(rectOf: CGSize(
            width: cellSize,
            height: cellSize
        ))
        // Set the position of the rectangle
        self.shape.position = CGPoint(x: x, y: y)
        // Set the fill color of the rectangle
        self.shape.fillColor = SKColor.white
        // Set the stroke color of the rectangle
        if show {
            self.shape.strokeColor = SKColor.black
        }
                    
    }
    
}
