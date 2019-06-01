/// Copyright (c) 2019 Razeware LLC
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


//CLASS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Ball: SKSpriteNode {
  static var members = [Ball]()
  
  class func createBall(xPos: CGFloat, yPos: CGFloat){
    let ball = Ball(imageName: "projectile")
    ball.position.x = xPos
    ball.position.y = yPos
    Ball.members.append(ball)
  }
  
  class func createBalls(num: Int, game: Game){
    var createBallCounter = 0
    while createBallCounter < 15 {
      createBall(xPos: game.gameScene.size.width/2, yPos: game.gameScene.size.height/2)
      createBallCounter += 1
    }
  }
  
  class func mean() -> CGFloat {
    var collection = [CGFloat]()
    for ball in Ball.members {
      collection.append(ball.currentSpeed())
    }
    let count = CGFloat(collection.count)
    var sum = CGFloat(0)
    for num in collection {
      sum += num
    }
    return sum / count
  }
  
  class func standardDev() -> CGFloat {
    let count = CGFloat(Ball.members.count)
    let mean = Ball.mean()
    var sumSq = CGFloat(0)
    for ball in Ball.members {
      let squaredDiff = pow(ball.currentSpeed() - mean, CGFloat(2))
      sumSq += squaredDiff
    }
    return sqrt(sumSq/count)
  }
  
  class func logStats(){
    var speedCollection = [CGFloat]()
    for ball in Ball.members{
      speedCollection.append(ball.currentSpeed())
      print("BALL STATS")
      print("Dx: \(ball.physicsBody!.velocity.dx)")
      print("Dy: \(ball.physicsBody!.velocity.dy)")
      print("Speed: \(ball.currentSpeed())")
    }
    print("GROUP STATS")
    print("Mean Speed: \(Ball.mean())")
    print("Speed SD: \(Ball.standardDev())")
  }
  
 class func startMovement(){
    for ball in Ball.members {
      let xVec = (CGFloat(arc4random_uniform(100)) / 50.0) * (CGFloat(arc4random_uniform(5)+1))
      let yVec = (CGFloat(arc4random_uniform(100)) / 50.0) * (CGFloat(arc4random_uniform(5)+1))
      let vector = CGVector(dx: xVec, dy: yVec)
      ball.physicsBody?.applyImpulse(vector)
    }
  }
  
  //INSTANCE/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  var isDistractor: Bool?
  var isTarget: Bool?
  
  init(imageName: String) {
    let texture = SKTexture(imageNamed: imageName)
    super.init(texture: texture, color: UIColor.clear, size: texture.size())
    self.size = CGSize(width: 30, height: 30)
    //physics setup
    self.physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: texture.size().width, height: texture.size().height))
    self.physicsBody?.isDynamic = true
    self.physicsBody?.allowsRotation = false
    self.physicsBody?.friction = 0
    self.physicsBody?.linearDamping = 0
    self.physicsBody?.restitution = 1
    self.physicsBody?.categoryBitMask = PhysicsCategory.ball
    self.physicsBody?.contactTestBitMask = PhysicsCategory.ball
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
  
  func currentSpeed() -> CGFloat {
    let aSq = pow(self.physicsBody!.velocity.dx,2.0)
    let bSq = pow(self.physicsBody!.velocity.dy,2.0)
    let cSq = aSq + bSq
    return CGFloat(sqrt(Float(cSq)))
  }
  
  func decelerate(){
    self.physicsBody?.velocity.dx *= 0.98
    self.physicsBody?.velocity.dy *= 0.98
    print("slowing")
  }
  
  func accelerate(){
    self.physicsBody?.velocity.dx *= 1.02
    self.physicsBody?.velocity.dy *= 1.02
    print("speeding")
    
  }
  
  
  
  
}
