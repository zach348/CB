

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
    if let gameWorld = currentGame.world, let timer = currentGame.timer {
      gameWorld.removeAction(forKey: "targetTimer")
      timer.members = timer.members.filter({ $0 != "targetTimer"})
      Ball.clearTargets()
      Ball.assignRandomTargets().forEach { ball in
        ball.removeAction(forKey: "blinkBall")
        ball.blinkBall()
        //testing
      }
      let targetTimer = SKAction.run {
        timer.recursiveTargetTimer()
      }
      gameWorld.run(targetTimer)
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
  
  class func getBall(name:String) -> Ball {
    return self.members.first(where: {$0.name == name })!
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
  
  class func hideBorders(){
    self.members.forEach({ $0.hideBorder()})
  }
  
  class func showBorders(){
    self.members.forEach({ $0.showBorder()})
  }
  
  class func resetTextures(){
    self.members.forEach({ ball in ball.texture = ball.isTarget ? Game.currentSettings.targetTexture : Game.currentSettings.distractorTexture })
  }
  
  class func enableInteraction() {
    self.members.forEach({ ball in ball.isUserInteractionEnabled = true })
  }
  
  class func disableInteraction() {
    self.members.forEach({ ball in ball.isUserInteractionEnabled = false })
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
  var border:SKShapeNode?
  
  let game:Game
  init() {
    let texture = Game.currentSettings.distractorTexture
    self.game = currentGame
    self.isTarget = false
    self.positionHistory = [CGPoint]()
    self.vectorHistory = [String:CGFloat]()
    self.border = SKShapeNode()
    super.init(texture: texture, color: UIColor.clear, size: texture.size())
    //border
    self.border = SKShapeNode(circleOfRadius: 24)
    if let border = self.border {
      border.fillColor = .clear
      border.strokeColor = UIColor.red
      border.lineWidth = 10
    }
    
    self.size = CGSize(width: 50, height: 50)
    self.name = "ball-\(Ball.members.count + 1)"
    self.isUserInteractionEnabled = false
    //physics setup
    self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2 * 0.95)
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
    self.border = SKShapeNode()
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
    Ball.blinkFlag = true
    let currentTexture = self.texture
    let setFlashTexture = SKAction.setTexture(Game.currentSettings.flashTexture)
    let resetTexture = SKAction.setTexture(currentTexture!)
    let fadeOut = SKAction.fadeOut(withDuration: 0.15)
    let fadeIn = SKAction.fadeIn(withDuration: 0.15)
    let fadeSequence = SKAction.repeat(SKAction.sequence([fadeOut, fadeIn]), count: 3)
    let blinkAction = SKAction.sequence([setFlashTexture, fadeSequence, resetTexture])
    let resetFlag = SKAction.run { Ball.blinkFlag = false }
    let wait = SKAction.wait(forDuration: Double.random(min: 0.5, max: 1))
    let resetSequence = SKAction.sequence([wait, resetFlag])
    let flagSequence = SKAction.sequence([blinkAction, resetSequence])
    self.run(flagSequence, withKey: "blinkBall")
  }
  
  func showBorder(){
    if let border = self.border { self.addChild(border) }
  }
  
  func hideBorder(){
    if let border = self.border { border.removeFromParent() }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    let touch:UITouch = touches.first! as UITouch
    let positionInScene = touch.location(in: self)
    let touchedNode = self.atPoint(positionInScene)
    if let name = touchedNode.name {
      if Ball.getTargets().map({$0.name}).contains(name) {
        print("Touched")
        Ball.getBall(name: name).showBorder()
      }
    }
  }
  
}

