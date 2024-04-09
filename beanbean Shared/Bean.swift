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
    var group: [Bean]
    var color: SKColor

    
    init(color: SKColor, cellSize: Int, startingPosition: CGPoint, showNumber: Bool) {
        let beanSize = CGSize(
            width: cellSize,
            height: cellSize
        )
        self.shape = SKShapeNode(
            rectOf: beanSize
        )
        
        // Set the position of the rectangle
        self.shape.position = startingPosition
        // Set the fill color of the rectangle
        self.shape.fillColor = SKColor.clear
        // Set the stroke color of the rectangle
        self.shape.strokeColor = SKColor.clear
        self.shape.zPosition = 0
        self.labelNode = SKLabelNode()
        self.checked = false
        self.color = color
        
        var beanImage: SKSpriteNode!
        
        if color == .gray{
            beanImage = createBean(beanSize: beanSize, bodyImage: "tile_grey", faceImage: "face_j")
        }
        switch self.color {
        case .green:
            beanImage = createBean(beanSize: beanSize, bodyImage: "green_body_circle", faceImage: "face_a")
        case .purple:
            beanImage = createBean(beanSize: beanSize, bodyImage: "purple_body_circle", faceImage: "face_b")
        case .red:
            beanImage = createBean(beanSize: beanSize, bodyImage: "red_body_circle", faceImage: "face_c")
        case .yellow:
            beanImage = createBean(beanSize: beanSize, bodyImage: "yellow_body_circle", faceImage: "face_d")
            
        default:
//            print("Unknown color")
            break
        }
        self.shape.addChild(beanImage) // Add the image node to the scene

//        self.beanImage = SKShapeNode(circleOfRadius: Double(cellSize) / 2)
//        self.beanImage.position = CGPoint(x:0, y:0)
//        self.beanImage.strokeColor = SKColor.black
//        self.beanImage.lineWidth = 3
//        self.beanImage.fillColor = color
//        self.shape.addChild(self.beanImage)
        

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
    
    func animationBeforeRemoved() {
        
        let shakeLeft = SKAction.move(by: CGVector(dx: 6, dy: 6), duration: 0.05)
        let shakeRight = SKAction.move(by: CGVector(dx: -6, dy: -6), duration: 0.05)
        
        var animationActions = [shakeLeft, shakeRight]
        let animationSequence = SKAction.sequence(animationActions)
        let repeatAnimationSequence = SKAction.repeatForever(animationSequence)
        self.shape.run(repeatAnimationSequence)
    }
}
func createBean(beanSize: CGSize, bodyImage: String, faceImage: String) -> SKSpriteNode {
    let body = SKSpriteNode(imageNamed: bodyImage)
    body.position = CGPoint(x: 0, y: 0)
    body.size = beanSize
    body.zPosition = 1
    
    let face = SKSpriteNode(imageNamed: faceImage)
    face.position = CGPoint(x: 0, y: 0)
    face.size = beanSize
    face.size = CGSize(
        width: beanSize.width / 1.7,
        height: beanSize.width / 1.7
    )
    face.zPosition = 2
    body.addChild(face)
    
    return body
}




