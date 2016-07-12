//
//  GameScene.swift
//  BreakOut
//
//  Created by Admin on 09.07.16.
//  Copyright (c) 2016 Sviridov. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fingerIsOnPaddle = false
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    var backgroungMusicPlayer = AVAudioPlayer()
    
    let ballCategory:UInt32 = 0x1 << 0
    let bottomCategory:UInt32 = 0x1 << 1
    let brickCategory:UInt32 = 0x1 << 2
    let paddleCategory:UInt32 = 0x1 << 3
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self
        
        
        let bgMusicURL:NSURL = NSBundle.mainBundle().URLForResource("bgMusic", withExtension: "mp3")!
        
        do {
            backgroungMusicPlayer = try AVAudioPlayer(contentsOfURL: bgMusicURL, fileTypeHint: nil)
        } catch {
            
            return
        }
        
        backgroungMusicPlayer.numberOfLoops = -1
        backgroungMusicPlayer.prepareToPlay()
        backgroungMusicPlayer.play()
        
        let backgroundImage = SKSpriteNode(imageNamed: "bg")
        backgroundImage.position = CGPointMake(self.frame.size.width / 2 , self.frame.size.height / 2)
        self.addChild(backgroundImage)
        
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = ballCategoryName
        ball.position = CGPointMake(self.frame.size.width / 3, self.frame.size.height / 3)
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        
        ball.physicsBody?.applyImpulse(CGVectorMake(2, -2))
        
        
        let paddle = SKSpriteNode(imageNamed: "paddle")
        paddle.name = paddleCategoryName
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 2)
        
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.dynamic = false
        
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect:bottomRect)
        
        self.addChild(bottom)
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        
        
        
        let numberOfRows = 3
        let numberOfBricks = 6
        let brickWidth = SKSpriteNode(imageNamed: "brick").size.width
        let padding:Float = 20
        
        let offset:Float = (Float(self.frame.size.width) - (Float(brickWidth) * Float(numberOfBricks) + padding * (Float(numberOfBricks) - 1))) / 2
        
        for index in 1 ... numberOfRows{
            
            var yOffset:CGFloat{
                switch index {
                case 1:
                    return self.frame.size.height * 0.8
                case 2:
                    return self.frame.size.height * 0.6
                case 3:
                    return self.frame.size.height * 0.4
                default:
                    return 0
                }
            }
            
            for index in 1...numberOfBricks{
                let brick = SKSpriteNode(imageNamed: "brick")
                
                let calc1:Float = Float(index) - 0.5
                let calc2:Float = Float(index) - 1
                
                brick.position = CGPointMake(CGFloat(calc1 * Float(brick.frame.size.width) + calc2 * padding + offset), yOffset)
                
                brick.physicsBody = SKPhysicsBody(rectangleOfSize: brick.frame.size)
                brick.physicsBody?.allowsRotation = false
                brick.physicsBody?.friction = 0
                brick.name = brickCategoryName
                brick.physicsBody?.categoryBitMask = brickCategory
                
                self.addChild(brick)
                
            }
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            let gameOverScene = GameOverScene(size: self.frame.size, playerWon: false)
            self.view?.presentScene(gameOverScene)
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory{
            secondBody.node?.removeFromParent()
            if isGameWon() {
                let youWinScene = GameOverScene(size: self.frame.size, playerWon: true)
                self.view?.presentScene(youWinScene)
            }
        }
    
        
        
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        for nodeObject in self.children{
            let node = nodeObject as SKNode
            if node.name == brickCategoryName {
                numberOfBricks += 1
            }
        }
        return numberOfBricks <= 0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        
        if body?.node?.name == paddleCategoryName {
            print("paddle touched")
            fingerIsOnPaddle = true
        }
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if fingerIsOnPaddle{
            let touch = touches.first
            let touchLoc = touch!.locationInNode(self)
            let prevTouchLoc = touch?.previousLocationInNode(self)
            
            let paddle = self.childNodeWithName(paddleCategoryName) as! SKSpriteNode
            
            var newXpos = paddle.position.x + (touchLoc.x - prevTouchLoc!.x)
            newXpos = max(newXpos, paddle.size.width / 2)
            newXpos = min(newXpos, self.size.width - paddle.size.width / 2)
            paddle.position = CGPointMake(newXpos, paddle.position.y)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        fingerIsOnPaddle = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
