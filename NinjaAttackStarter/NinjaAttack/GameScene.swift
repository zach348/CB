/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let ball   : UInt32 = 0b1       // 1
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
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


class GameScene: SKScene {
  // 1
//  let player = SKSpriteNode(imageNamed: "player")
  
  override func didMove(to view: SKView) {
    
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    //scene setup
    self.backgroundColor = .white
    self.scaleMode = .aspectFit
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    
    //create ball
    var ballGroup = BallGroup(gameScene: self)
    var createBallCounter = 0
    //create balls
    while createBallCounter < 15 {
      ballGroup.createBall()
      createBallCounter += 1
    }
    //add balls to scene
    ballGroup.addMemberstoScene()
    ballGroup.startMovement()
    

    //physics setup
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    
//    func addMonster() {
//
//      // Create sprite
//      let monster = SKSpriteNode(imageNamed: "monster")
//
//      // Determine where to spawn the monster along the Y axis
//      let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
//
//      // Position the monster slightly off-screen along the right edge,
//      // and along a random position along the Y axis as calculated above
//      monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
//
//      // Add the monster to the scene
//      addChild(monster)
//
//      // Determine speed of the monster
//      let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
//
//      // Create the actions
//      let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
//                                     duration: TimeInterval(actualDuration))
//      let actionMoveDone = SKAction.removeFromParent()
//      monster.run(SKAction.sequence([actionMove, actionMoveDone]))
//    }
    

    
    
    
//    run(SKAction.repeatForever(
//      SKAction.sequence([
//        SKAction.run(addMonster),
//        SKAction.wait(forDuration: 1.0)
//        ])
//    ))
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
}
