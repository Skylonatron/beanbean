//
//  UI.swift
//  beanbean
//
//  Created by Skylar Jones on 3/29/24.
//

import SpriteKit

func outline(width: CGFloat, height: CGFloat, lineWidth: CGFloat) -> SKShapeNode {
    let outline = SKShapeNode(rectOf: CGSize(
        width: width,
        height: height
    ))
    outline.fillColor = .white
    outline.strokeColor = .darkGray
    outline.lineWidth = lineWidth
    
    return outline
}
