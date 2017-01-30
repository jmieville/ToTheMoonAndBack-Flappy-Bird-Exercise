//
//  GameScene.swift
//  Jumpy Fish
//
//  Created by Jean-Marc Kampol Mieville on 10/19/2559 BE.
//  Copyright © 2559 Jean-Marc Kampol Mieville. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var gameOver = false
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    let ground = SKNode()
    let sky = SKNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOverText = SKLabelNode()
    var timer = Timer()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    
    func makePipes() {
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let gapHeight = bird.size.height * 4
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffSet = CGFloat(movementAmount) - self.frame.height / 4
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        
        pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffSet)
        pipe1.run(moveAndRemovePipes)

        //pipe1.size.height = self.frame.height
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(pipe1)

        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffSet)
        pipe2.run(moveAndRemovePipes)

        //pipe2.size.height = self.frame.height
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe2.physicsBody!.isDynamic = false
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(pipe2)

        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffSet)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)

        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                print("Add one to score")
                scoreLabel.text = String(score)
                
            } else {
                
                print("we have contact")
                
                timer.invalidate()
                
                self.speed = 0
                gameOver = true
                gameOverText.zPosition = 1
                gameOverText.fontName = "Helvetica"
                gameOverText.fontSize = 30
                gameOverText.text = "You lose! Tap to play again"
                self.addChild(gameOverText)

            }
        
        }
    }
    
    func StartGame() {
        self.physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        
        let backGround = SKTexture(imageNamed: "bg.png")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backGround.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: backGround.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        
        let movingBGAnimation = SKAction.repeatForever(moveBGAnimation)
        
        
        
        var i: CGFloat = 0
        
        while i < 3{
            bg = SKSpriteNode(texture: backGround)
            bg.position = CGPoint(x: backGround.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            //bg.size = CGSize(width: self.frame.width, height: self.frame.height)
            bg.run(moveBGForever)
            self.addChild(bg)
            i += 1
            bg.zPosition = -1
            bird.zPosition = 2
        }
        
        
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        
        
        
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        self.addChild(bird)

        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        
        
        sky.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        sky.physicsBody!.isDynamic = false
        
        self.addChild(sky)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 30
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel) 
    }

    override func didMove(to view: SKView) {
        StartGame()
                    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)


            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 88))
        
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            
            StartGame()           
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //bird.physicsBody!.
    }
        
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
