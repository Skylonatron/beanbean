//
//  GameViewController.swift
//  beanbean macOS
//
//  Created by Skylar Jones on 3/7/24.
//

import Cocoa
import SpriteKit
import GameplayKit
import GameKit
import Cocoa

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let scene = HomeScene.newHomeScene()
//        let scene = GameScene.newGameScene(mode: .single)
        
        // Present the scene
//        let skView = self.view as! SKView
//        skView.presentScene(scene)
        
//        skView.ignoresSiblingOrder = true
//        
//        skView.showsFPS = true
//        skView.showsNodeCount = true

        if !GKLocalPlayer.local.isAuthenticated {
            // Player is not authenticated, authenticate now
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let viewController = viewController {
                    // If there's a view controller returned, present it to allow the player to authenticate
                    self.present(viewController, animator: DefaultAnimator())
                } else if let error = error {
                    // Handle authentication error
                    print("Authentication failed: \(error.localizedDescription)")
                } else {
                    // Player is authenticated
//                    let scene = GameScene.newGameScene(mode: .single)
                    let scene = HomeScene.newHomeScene()
                    
                    // Present the scene
                    let skView = self.view as! SKView
                    skView.presentScene(scene)
                    
                    skView.ignoresSiblingOrder = true
                    
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    print("Player authenticated successfully!")
                }
            }
        } else {
            // Player is already authenticated
            print("Player already authenticated!")
        }
    }
}

class DefaultAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        viewController.view.frame.origin = fromViewController.view.frame.origin
        fromViewController.view.addSubview(viewController.view)
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        viewController.view.removeFromSuperview()
    }
}
