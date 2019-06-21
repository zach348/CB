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
  static var blinkFlag: Bool = false {
    didSet {
      if self.pendingPause && !self.blinkFlag {
        currentGame.pauseGame()
        self.pendingPause = false
      }
    }
  }
  static var pendingPause:Bool = false
  
  class func createBall(game: Game, xPos: CGFloat, yPos: CGFloat){
    let ball = Ball()
    ball.position.x = xPos
    ball.position.y = yPos
    Ball.members.append(ball)
  }
  
  class func createBalls(num: Int, game: Game){
    if let scene = currentGame.gameScene {
      var createBallCounter = 0
      while createBallCounter < num {
        createBall(game: game, xPos: scene.size.width/2, yPos: scene.size.height/2)
        createBallCounter += 1
      }
    }
  }
  
  class func mean() -> CGFloat {
    var collection = [CGFloat]()
    var sum = CGFloat(0)
    let count = CGFloat(Ball.members.count)
    for ball in Ball.members {
      collection.append(ball.currentSpeed())
      sum += ball.currentSpeed()
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
      let xVec = CGFloat.random(min: -75, max: 75)
      let yVec = CGFloat.random(min: -75, max: 75)
      let vector = CGVector(dx: xVec, dy: yVec)
      ball.physicsBody?.applyImpulse(vector)
    }
  }
  
  class func shiftTargets(){
      Ball.clearTargets()
      Ball.assignRandomTargets().forEach { ball in
        ball.removeAction(forKey: "blinkBall")
        ball.blinkBall()
      //testing
      }
  }
  
  class func assignRandomTargets() -> [Ball] {
    var newTargets = [Ball]()
    var counter = 0
    while counter < Game.currentSettings.numTargets {
      let randomIndex = Int.random(min: 0, max: self.members.count - 1)
      let newTarget = self.members[randomIndex]
      if !newTargets.contains(newTarget) {
        newTarget.isTarget = true
        newTargets.append(newTarget)
        counter += 1
      }
    }
    return newTargets
  }
  
  class func getTargets() -> [Ball]{
    return self.members.filter { ball in
      ball.isTarget
    }
  }
  
  class func getDistractors() -> [Ball] {
    return self.members.filter { ball in
      !ball.isTarget
    }
  }
  
  class func clearTargets(){
    for ball in self.members {
      ball.isTarget = false
    }
  }
  
  class func freezeMovement(){
    if let scene = currentGame.gameScene {
      scene.physicsWorld.speed = 0
    }
  }
  
  class func unfreezeMovement(){
    if let scene = currentGame.gameScene {
      scene.physicsWorld.speed = 1
    }
  }
  
  class func maskTargets() {
    self.getTargets().forEach({ target in target.texture = Game.currentSettings.distractorTexture })
  }
  
  class func unmaskTargets() {
    self.getTargets().forEach({ target in target.texture = Game.currentSettings.targetTexture })
  }
  
  class func resetTextures(){
    self.members.forEach({ ball in ball.texture = ball.isTarget ? Game.currentSettings.targetTexture : Game.currentSettings.distractorTexture })
  }
//INSTANCE/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  var isTarget:Bool {
    didSet {
      if isTarget { self.texture = Game.currentSettings.targetTexture }
      else { self.texture = Game.currentSettings.distractorTexture }
    }
  }
  var positionHistory:[CGPoint]
  var vectorHistory:[String:CGFloat]
  let game:Game
  init() {
    let texture = Game.currentSettings.distractorTexture
    self.game = currentGame
    self.isTarget = false
    self.positionHistory = [CGPoint]()
    self.vectorHistory = [String:CGFloat]()
    super.init(texture: texture, color: UIColor.clear, size: texture.size())
    self.size = CGSize(width: 50, height: 50)
    self.name = "ball-\(Ball.members.count + 1)"
    //physics setup
    self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2 * 0.9)
    self.physicsBody?.isDynamic = true
    self.physicsBody?.allowsRotation = false
    self.physicsBody?.friction = 0
    self.physicsBody?.linearDamping = 0
    self.physicsBody?.restitution = 1
    self.physicsBody?.categoryBitMask = PhysicsCategory.ball
    self.physicsBody?.contactTestBitMask = PhysicsCategory.ball
  }

  required init?(coder aDecoder: NSCoder) {
    self.game = currentGame
    self.isTarget = false
    self.positionHistory = [CGPoint]()
    self.vectorHistory = [String:CGFloat]()
    super.init(coder:aDecoder)
  }
  
  func updatePositionHistory() {
    self.positionHistory.append(self.position)
    if self.positionHistory.count > 10 { self.positionHistory.removeFirst() }
  }
  
  func ballStuckX() -> Bool {
    if let lastXVal = self.positionHistory.last?.x {
      for position in self.positionHistory {
        if position.x != lastXVal { return false }
      }
    }
    return true
  }
  
  func ballStuckY() -> Bool {
    if let lastYVal = self.positionHistory.last?.y {
      for position in self.positionHistory {
        if position.y != lastYVal { return false }
      }
    }
    return true
  }
  
  
  func currentSpeed() -> CGFloat {
    let aSq = pow(self.physicsBody!.velocity.dx,2.0)
    let bSq = pow(self.physicsBody!.velocity.dy,2.0)
    let cSq = aSq + bSq
    return sqrt(CGFloat(cSq))
  }
  
  func modifySpeed(factor:CGFloat){
    self.physicsBody?.velocity.dx *= factor
    self.physicsBody?.velocity.dy *= factor
  }
  
  func blinkBall(){
    if let currentTexture = self.texture {
      Ball.blinkFlag = true
      let setFlashTexture = SKAction.setTexture(Game.currentSettings.flashTexture)
      let resetTexture = SKAction.setTexture(currentTexture)
      let fadeOut = SKAction.fadeOut(withDuration: 0.15)
      let fadeIn = SKAction.fadeIn(withDuration: 0.15)
      let fadeSequence = SKAction.repeat(SKAction.sequence([fadeOut, fadeIn]), count: 3)
      let blinkAction = SKAction.sequence([setFlashTexture, fadeSequence, resetTexture])
      let resetFlag = SKAction.run { Ball.blinkFlag = false }
      let flagSequence = SKAction.sequence([blinkAction, resetFlag])
      self.run(flagSequence, withKey: "blinkBall")
    }
  }
}
