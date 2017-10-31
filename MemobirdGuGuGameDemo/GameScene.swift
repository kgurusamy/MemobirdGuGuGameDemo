//
//  GameScene.swift
//  MemobirdGuGuGameDemo
//
//  Created by Kumaravel on 24/10/17.
//  Copyright © 2017 Oottru. All rights reserved.
//

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
 
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
 
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
 
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
 
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif
 
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
 
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Monster   : UInt32 = 0b1       // 1
  static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // 1
  let player = SKSpriteNode(imageNamed: "player")
  var monstersDestroyed = 0
  let myLabel = SKLabelNode(fontNamed:"Chalkduster")
 
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.white
    // 3
    player.position = CGPoint(x: size.width * 0.5, y: size.height * (0.1)/2)
    // 4
    addChild(player)
    
    myLabel.text = ""
    myLabel.fontColor = SKColor.black
    myLabel.fontSize = 20
    myLabel.position = CGPoint(x:(self.view?.center.x)!, y:(self.view?.center.y)!+300)
    self.addChild(myLabel)
    
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 0.5), // Speed of the monster
        SKAction.run(addMonster_black),
        SKAction.wait(forDuration: 0.5) // Speed of the monster
      ])
    ))

    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
    
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
   
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
   
  func addMonster() {
   
    // Create sprite
    let monster = SKSpriteNode(imageNamed: "monster")
    monster.name = "bluebird"
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
    monster.physicsBody?.isDynamic = true // 2
    monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
    monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
   
    // Determine where to spawn the monster along the Y axis
    let actualY = random(min: (size.height*0.5), max: (size.height-monster.size.height*2))
   
    // Position the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
    
    // Add the monster to the scene
    addChild(monster)
   
    // Determine speed of the monster
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(5.0))
   
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()

    /*let loseAction = SKAction.run() {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }*/
    monster.run(SKAction.sequence([actionMove, /*loseAction, */actionMoveDone]))
   
  }
    
    func addMonster_black() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster_black")
        monster.name = "blackbird"
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: (size.height*0.5), max: (size.height-monster.size.height*2))
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(5.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        /*let loseAction = SKAction.run() {
         let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
         let gameOverScene = GameOverScene(size: self.size, won: false)
         self.view?.presentScene(gameOverScene, transition: reveal)
         }*/
        monster.run(SKAction.sequence([actionMove, /*loseAction, */actionMoveDone]))
        
    }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
   
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    projectile.name = "projectile"
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
    projectile.physicsBody?.usesPreciseCollisionDetection = true
   
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - projectile.position
   
    // 4 - Bail out if you are shooting down or backwards
    if (offset.y < 0) { return }
   
    // 5 - OK to add now - you've double checked position
    addChild(projectile)
   
    // 6 - Get the direction of where to shoot
    let direction = offset.normalized()
    //print("direction : \(direction)")
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
    
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + projectile.position
   
    // 9 - Create the actions
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
   
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))

  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    //print("Hit")
    if(monster.name == "bluebird")
    {
        myLabel.alpha = 1.0
        myLabel.text = "You hit bluebird"
        myLabel.run(SKAction.fadeOut(withDuration: 1.5))
        print("You hit bluebird")
    }
    else if(monster.name == "blackbird")
    {
        myLabel.alpha = 1.0
        myLabel.text = "you hit blackbird"
        myLabel.run(SKAction.fadeOut(withDuration: 1.5))
        print("you hit blackbird")
    }
    
    projectile.removeFromParent()
    monster.removeFromParent()
    
    monstersDestroyed += 1
    if (monstersDestroyed > 30) {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {

    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode, let
        projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
      
    }
  }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // ... every other update logic
       
       /* for node in nodesToCheck {
            if node.position.y < -node.size.height/2.0 {
                node.removeFromParent()
                gameOver()
            }
        }*/
        
        // Loop over all nodes in the scene
        self.enumerateChildNodes(withName: "projectile") {
            node, stop in
            if (node is SKSpriteNode) {
                
                let projectile = node as! SKSpriteNode
                if(projectile.name == "projectile")
                {
                    if(projectile.position.x < 0 || projectile.position.x > self.size.width || projectile.position.y > self.size.height){
                        self.myLabel.alpha = 1.0
                        self.myLabel.text = "target missed!"
                        self.myLabel.run(SKAction.fadeOut(withDuration: 1.5))
                        print("target missed!")
                    }
                 
                    //print("Y Position : \(projectile.position.y)")
                }
                // Check if the node is not in the scene
                /*if (sprite.position.x < -sprite.size.width/2.0 || sprite.position.x > self.size.width+sprite.size.width/2.0
                    || sprite.position.y < -sprite.size.height/2.0 || sprite.position.y > self.size.height+sprite.size.height/2.0) {
                    sprite.removeFromParent()
                }*/
            }
        }
    }

}


