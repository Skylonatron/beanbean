//
//  GameScene.swift
//  beanbean Shared
//
//  Created by Skyler Jomes and Salmon Willemsum on 3/7/24.
//sss

import SpriteKit

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
        soloButton.position = CGPoint(x: 0, y: frame.width / 10)
        outline.addChild(soloButton)
        
        let multiButton = addButton(outlineFrame: outline.frame, name: "Multi")
        multiButton.position = CGPoint(x: 0, y: 0)
        outline.addChild(multiButton)
        
        let matchmakingButton = addButton(outlineFrame: outline.frame, name: "Online")
        matchmakingButton.position = CGPoint(x: 0, y: -frame.width / 10)
        outline.addChild(matchmakingButton)
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
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            
        }
        if node.name == "Multi" {
            let gameScene = GameScene.newGameScene(mode: .localMultiplayer)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            
        }
        if node.name == "Online" {
            let matchmakingScene = MatchmakingScene.newMatchmakingScene()
            matchmakingScene.scaleMode = .aspectFill
            self.view?.presentScene(matchmakingScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
}
#endif

#if os(iOS) || os(tvOS)

extension HomeScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        // Check if touch intersects with the node's frame
        if node.name == "Solo" {
            let gameScene = GameScene.newGameScene(mode: .single)
            self.view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
        if node.name == "Online" {
            let matchmakingScene = MatchmakingScene.newMatchmakingScene()
            matchmakingScene.scaleMode = .aspectFill
            self.view?.presentScene(matchmakingScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
}



#endif
