//
//  GameViewController.swift
//  beanbean iOS
//
//  Created by Skylar Jones on 3/7/24.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if !GKLocalPlayer.local.isAuthenticated {
            // Player is not authenticated, authenticate now
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let viewController = viewController {
                    // If there's a view controller returned, present it to allow the player to authenticate
                    self.present(viewController, animated: true)
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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
