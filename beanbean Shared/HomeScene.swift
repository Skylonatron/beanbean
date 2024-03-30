//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit
//import UIKit

class HomeScene: SKScene {
    
    var game: Game!
        
    class func newHomeScene() -> HomeScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = HomeScene()
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        let outline = outline(
            width: self.size.width / 2,
            height: self.size.height / 2,
            lineWidth: 8
        )
        self.addChild(outline)

        let soloButton = addButton(outlineFrame: outline.frame, name: "Solo")
        soloButton.position = CGPoint(x: 0, y: frame.width / 20)
        outline.addChild(soloButton)
        
        let multiButton = addButton(outlineFrame: outline.frame, name: "Multi")
        multiButton.position = CGPoint(x: 0, y: -frame.width / 20)
        outline.addChild(multiButton)
    }
    
    func addButton(outlineFrame: CGRect, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(
            width: frame.width / 10,
            height: frame.height / 10
        ))
        button.position = CGPoint(x: 0, y: 0)
        button.fillColor = SKColor.white
        button.strokeColor = SKColor.black
        button.lineWidth = 8
        button.name = name
        
        let labelNode = SKLabelNode()
        labelNode.text = name
        labelNode.name = name
        labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        labelNode.fontColor = .black
        labelNode.fontSize = 40
        labelNode.fontName = "ChalkboardSE-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        button.addChild(labelNode) // Add label as child of shape node
        return button
    }
    
    
    override func didMove(to view: SKView) {
//        self.size = view.bounds.size
        self.size = CGSize(width: 1366.0, height: 1024.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }

}

#if os(OSX)
// Mouse-based event handling
extension HomeScene {

    override func mouseDown(with event: NSEvent) {
        // for debugging you can click on a cell and see if there is a bean there
        let location = event.location(in: self)
        let node = self.atPoint(location)
        if node.name == "Solo" {
            let gameScene = GameScene.newGameScene(mode: .single)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenVertical(withDuration: 1.0))
//            SKTransition.doorsCloseVertical(withDuration: 1.0)

//            GameViewController.viewDidLoad(GameViewController)
        }
//        let cell = self.grid.getCell(x: location.x + CGFloat(self.grid.cellSize / 2), y: location.y + CGFloat(self.grid.cellSize / 2))
//        print(cell?.bean)
    }
}
#endif

