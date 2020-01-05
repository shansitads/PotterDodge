//
//  GameScene.swift
//  potterdodge
//
//  Created by Shansita on 23/12/19.
//  Copyright © 2019 Shansita Das Sharma. All rights reserved.
//

import SpriteKit
import AVFoundation


//MARK:- NEW PROTOCOL 1
protocol TransitionDelegate: SKSceneDelegate {
    func returnToMainMenu()
}




class GameScene: SKScene, SKPhysicsContactDelegate{
    let verticalHoopsGap = 150.0
    
    var potter:SKSpriteNode!
    var skyColor:SKColor!
    var hoopTextureUp:SKTexture!
    var hoopTextureDown:SKTexture!
    var moveHoopsAndRemove:SKAction!
    var moving:SKNode!
    var hoops:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    var lightning = SKSpriteNode()
    
    var audioPlayer1 = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()
    
    let potterCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let hoopCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    
    
    override func didMove(to view: SKView) {
        
        canRestart = true
        
        // setup physics
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -5.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        skyColor = SKColor(red: 46.0/255.0, green: 48.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        moving = SKNode()
        self.addChild(moving)
        hoops = SKNode()
        moving.addChild(hoops)
        
        // setup background thunder sound
        var soundURL = Bundle.main.url(forResource: "thunder-ongoing", withExtension: "wav")
        do{
            audioPlayer1 = try AVAudioPlayer(contentsOf: soundURL!)
        }
          catch
            {print("No sound found by URL")}
        audioPlayer1.numberOfLoops = -1
        audioPlayer1.play()
        
        // setup thunderbolt sound
        soundURL = Bundle.main.url(forResource: "thunderbolt", withExtension: "wav")
        do{
            audioPlayer2 = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch
        {print("No sound found by URL")}
        
        
        
        // ground
        let groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / ( groundTexture.size().width * 2 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // skyline
        let skyTexture = SKTexture(imageNamed: "potter-sky")
        skyTexture.filteringMode = .nearest
        
        let moveSkySprite = SKAction.moveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.1 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / ( skyTexture.size().width * 2 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
        }
        
        // create the hoops textures
        hoopTextureUp = SKTexture(imageNamed: "hoopUp")
        hoopTextureUp.filteringMode = .nearest
        hoopTextureDown = SKTexture(imageNamed: "hoopDown")
        hoopTextureDown.filteringMode = .nearest
        
        // create the hoops movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * hoopTextureUp.size().width)
        let moveHoops = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(0.01 * distanceToMove))
        let removeHoops = SKAction.removeFromParent()
        moveHoopsAndRemove = SKAction.sequence([moveHoops, removeHoops])
        //create needle head movement actions
        
        // spawn the hoops
        let spawn = SKAction.run(spawnHoops)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        
        
        //setup lightning
        lightning = SKSpriteNode(imageNamed: "lightning")
        lightning.setScale(1.5)
        lightning.position = CGPoint(x: self.frame.size.width / 2, y:self.frame.size.height / 2)
        self.addChild(lightning)
        lightning.isHidden = true;
        
        
        
        // setup potter
        
        
        let gameInfo = self.userData?.value(forKey: "gameInfo")
        let potterTexture1 = SKTexture(imageNamed: gameInfo as! String)
        potterTexture1.filteringMode = .nearest
        
        
        potter = SKSpriteNode(texture: potterTexture1)
        potter.setScale(0.13)
        potter.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        
        
        potter.physicsBody = SKPhysicsBody(circleOfRadius: potter.size.height / 2.0)
        potter.physicsBody?.isDynamic = true
        potter.physicsBody?.allowsRotation = false
        
        potter.physicsBody?.categoryBitMask = potterCategory
        potter.physicsBody?.collisionBitMask = worldCategory | hoopCategory
        potter.physicsBody?.contactTestBitMask = worldCategory | hoopCategory
        
        self.addChild(potter)
        
        
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
    }
    
    func spawnHoops() {
        let hoopPair = SKNode()
        hoopPair.position = CGPoint( x: self.frame.size.width + hoopTextureUp.size().width * 2, y: 0 )
        hoopPair.zPosition = -10
        
        let height = UInt32( self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let hoopDown = SKSpriteNode(texture: hoopTextureDown)
        hoopDown.setScale(2.0)
        hoopDown.position = CGPoint(x: 0.0, y: y + Double(hoopDown.size.height) + verticalHoopsGap)
        
        
        
        
        hoopDown.physicsBody = SKPhysicsBody(rectangleOf: hoopDown.size)
        hoopDown.physicsBody?.isDynamic = false
        hoopDown.physicsBody?.categoryBitMask = hoopCategory
        hoopDown.physicsBody?.contactTestBitMask = potterCategory
        hoopPair.addChild(hoopDown)
        
        let hoopUp = SKSpriteNode(texture: hoopTextureUp)
        hoopUp.setScale(2.0)
        hoopUp.position = CGPoint(x: 0.0, y: y)
        
        hoopUp.physicsBody = SKPhysicsBody(rectangleOf: hoopUp.size)
        hoopUp.physicsBody?.isDynamic = false
        hoopUp.physicsBody?.categoryBitMask = hoopCategory
        hoopUp.physicsBody?.contactTestBitMask = potterCategory
        hoopPair.addChild(hoopUp)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: hoopDown.size.width + potter.size.width / 2, y: self.frame.midY )
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: hoopUp.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = potterCategory
        hoopPair.addChild(contactNode)
        
        hoopPair.run(moveHoopsAndRemove)
        hoops.addChild(hoopPair)
        
    }
    
    func resetScene (){
        // Move potter to original position and reset velocity
        potter.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        potter.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        potter.physicsBody?.collisionBitMask = worldCategory | hoopCategory
        potter.speed = 1.0
        potter.zRotation = 0.0
        
        hoops.removeAllChildren()
        canRestart = false
        score = 0
        scoreLabelNode.text = String(score)
        
        
        
        //MARK:- NEW 2
        self.run(SKAction.wait(forDuration: 2),completion:{[unowned self] in
            guard let delegate = self.delegate else { return }
            self.view?.presentScene(nil)
            (delegate as! TransitionDelegate).returnToMainMenu()
        })
        
        
        
        // Restart animation
        moving.speed = 1
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0  {
            for _ in touches { //need all touches?
                potter.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                potter.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
            }
        } else if canRestart {
            self.resetScene()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let value = potter.physicsBody!.velocity.dy * ( potter.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )
        potter.zRotation = min( max(-1, value), 0.5 )
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // potter has contact with score
                score += 1
                scoreLabelNode.text = String(score)
                
                // Visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
            } else {
                
                moving.speed = 0
                
                potter.physicsBody?.collisionBitMask = worldCategory
                potter.run(  SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(potter.position.y) * 0.01, duration:1), completion:{self.potter.speed = 0 })
                
                //
                // Contact is detected - lightning, red flash
                self.removeAction(forKey: "flash")
                self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.run({
                    self.audioPlayer2.play()
                    self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                    self.lightning.isHidden = false
                }),SKAction.wait(forDuration: TimeInterval(0.05)), SKAction.run({
                    self.backgroundColor = self.skyColor
                    self.lightning.isHidden = true
                }), SKAction.wait(forDuration: TimeInterval(0.05))]), count:4), SKAction.run({
                    self.canRestart = true
                })]), withKey: "flash")
            }
        }
    }
}
