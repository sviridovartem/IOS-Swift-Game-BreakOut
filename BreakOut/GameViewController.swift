//
//  GameViewController.swift
//  BreakOut
//
//  Created by Admin on 09.07.16.
//  Copyright (c) 2016 Sviridov. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let skView = self.view as! SKView
        if skView.scene == nil {
            skView.showsFPS = true;
            skView.showsNodeCount = true;
            
            let gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            
            skView.presentScene(gameScene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
