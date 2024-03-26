//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit
//import UIKit

class HomeScene: SKScene {
        
    class func newHomeScene() -> HomeScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = HomeScene()
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        let bounds = self.view!.bounds
        print(bounds.width)
        print(self.size.width)
      
        let button = SKShapeNode(rectOf: CGSize(
            width: 100,
            height: 50
        ))
        button.position = CGPoint(x: self.size.width / 2, y: self.size.width / 2)
        button.fillColor = SKColor.white
        button.strokeColor = SKColor.green
        button.lineWidth = 4
        button.name = "Start"
        
        let labelNode = SKLabelNode()
        labelNode.text = "Start"
        labelNode.name = "Start"
        labelNode.position = CGPoint(x: 0, y: 0) // Adjust position relative to shape node
        labelNode.fontColor = .black
        labelNode.fontSize = 25
        labelNode.fontName = "ChalkboardSE-Bold"
        labelNode.horizontalAlignmentMode = .center // Center horizontally
        labelNode.verticalAlignmentMode = .center // Center vertically
        button.addChild(labelNode) // Add label as child of shape node
        self.addChild(button)
    
    }
    
    func addButton() {
       
    }
    
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
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
        print(node.name)
        if node.name == "Start" {
            let gameScene = GameScene.newGameScene()
            self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))

//            GameViewController.viewDidLoad(GameViewController)
        }
//        let cell = self.grid.getCell(x: location.x + CGFloat(self.grid.cellSize / 2), y: location.y + CGFloat(self.grid.cellSize / 2))
//        print(cell?.bean)
    }
}
#endif

