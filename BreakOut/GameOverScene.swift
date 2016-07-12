//
//  GameOverScene.swift
//  BreakOut
//
//  Created by Admin on 12.07.16.
//  Copyright © 2016 Sviridov. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    init(size:CGSize, playerWon:Bool){
        super.init(size: size)
        let background = SKSpriteNode(imageNamed: "bg")
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        
        if playerWon {
        gameOverLabel.text = "You Win"
        } else {
            gameOverLabel.text = "Game Over"
        }
        
        self.addChild(gameOverLabel)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let breakoutGameScene = GameScene(size: self.size)
        self.view?.presentScene(breakoutGameScene)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
