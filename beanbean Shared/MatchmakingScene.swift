//
//  MatchmakingScene.swift
//  beanbean
//
//  Created by Sam Willenson on 4/12/24.
//

import SpriteKit
import GameKit

class MatchmakingScene: SKScene {
    var game: Game!
    
//    override func didMove(to view: SKView) {
//        
//    }
    
    class func newMatchmakingScene() -> MatchmakingScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = MatchmakingScene()
        
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
        
        let backButton = addButton(outlineFrame: outline.frame, name: "Back")
        backButton.position = CGPoint(x: 0, y: frame.width / 10)
        outline.addChild(backButton)
        
        let findMatchButton = addButton(outlineFrame: outline.frame, name: "FindMatch")
        findMatchButton.position = CGPoint(x: 0, y: -frame.width / 10)
        outline.addChild(findMatchButton)
        
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
extension MatchmakingScene: GKMatchmakerViewControllerDelegate {
    func initiateMatchmaking(){
        guard GKLocalPlayer.local.isAuthenticated else{
            print("Player is not authenticated.")
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        
        guard let viewController = matchmakerViewController else{
            print("Failed to create matchmaker view controller.")
            return
        }
        
        self.view?.window?.contentViewController?.presentAsSheet(viewController)
    }
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaking failed with error: \(error.localizedDescription)")
    }
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(true)
        let gameScene = GameScene(match: match)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: .doorsOpenHorizontal(withDuration: 1.0))
    }
    
    
    override func mouseDown(with event: NSEvent) {
        // for debugging you can click on a cell and see if there is a bean there
        let location = event.location(in: self)
        let node = self.atPoint(location)
        if node.name == "Back" {
            let homeScene = HomeScene.newHomeScene()
            homeScene.scaleMode = .aspectFill
            view?.presentScene(homeScene, transition: .doorsCloseHorizontal(withDuration: 1.0))
        }
        if node.name == "FindMatch" {
            initiateMatchmaking()
        }
    }
    

}
#endif
