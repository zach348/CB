

import SpriteKit

//CLASS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Ball: SKSpriteNode {
  static var members = [Ball]()
  static var blinkFlags = [Bool]() {
    didSet {
      if self.pendingPause && self.blinkFlags.isEmpty {
        currentGame.pauseGame()
        self.pendingPause = false
      }
      if self.pendingShift && self.blinkFlags.isEmpty {
        self.shiftTargets()
      }
    }
  }
  static var pendingPause:Bool = false
  static var pendingShift = false
  
  class func ballStats(){
    print("Mean Speed:", self.mean(), "SD:", self.standardDev())
  }
  class func createBall(game: Game, xPos: CGFloat, yPos: CGFloat){
    let ball = Ball()
    ball.position.x = xPos
    ball.position.y = yPos
    Ball.members.append(ball)
  }
  
  class func createBalls(num: Int, game: Game){
    var createBallCounter = 0
    while createBallCounter < num {
      createBall(game: game, xPos: 0, yPos: 0)
      createBallCounter += 1
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
  
 class func startMovement(){
    for ball in Ball.members {
      let xVec = CGFloat.random(min: -75, max: 75)
      let yVec = CGFloat.random(min: -75, max: 75)
      let vector = CGVector(dx: xVec, dy: yVec)
      ball.physicsBody?.applyImpulse(vector)
    }
  }

  class func shiftTargets(){
    if !self.blinkFlags.isEmpty {
      self.pendingShift = true
      print("pending shift")
      return
    }else if let worldTimer = currentGame.worldTimer, let timer = currentGame.timer {
      timer.stopTimer(timerID: "targetTimer")
      Ball.clearTargets()
      Ball.assignRandomTargets().forEach { ball in
        ball.removeAction(forKey: "blinkBall")
        Sensory.blinkBall(ball: ball)
        //testing
      }
      let targetTimer = SKAction.run {
        timer.targetTimer()
      }
      worldTimer.run(targetTimer)
    }
  }
  
  class func assignRandomTargets() -> [Ball] {
    var newTargets = [Ball]()
    var counter = 0
    while counter < Game.currentTrackSettings.numTargets {
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
  
  class func addTarget(){
    if let newTarget = Ball.getDistractors().randomElement(){
      newTarget.isTarget = true
      Sensory.blinkBall(ball: newTarget)
    }
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
    self.getTargets().forEach({ target in
      target.texture = Game.currentTrackSettings.distractorTexture
      target.alpha = Game.currentTrackSettings.alpha
    })
  }
  
  class func unmaskTargets() {
    self.getTargets().forEach({ target in
      target.texture = Game.currentTrackSettings.targetTexture
      target.alpha = Game.currentTrackSettings.alpha
    })
  }
  
  class func removeEmitters(){
    for ball in self.members {
      ball.removeParticles()
    }
  }
  
  class func hideBorders(){
    self.members.forEach({ $0.hideBorder()})
  }
  
  class func showBorders(){
    self.members.forEach({ $0.showBorder()})
  }
  
  class func resetTextures(){
    self.members.forEach({ ball in
      ball.texture = ball.isTarget ? Game.currentTrackSettings.targetTexture : Game.currentTrackSettings.distractorTexture
      ball.alpha = Game.currentTrackSettings.alpha
    })
  }
  
  class func resetFoundTargets(){
    for ball in self.members {
      ball.foundTarget = false
    }
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
      if isTarget { self.texture = Game.currentTrackSettings.targetTexture }
      else { self.texture = Game.currentTrackSettings.distractorTexture }
    }
  }
  var positionHistory:[CGPoint]
  var vectorHistory:[String:CGFloat]
  var border:SKShapeNode?
  var foundTarget = false
  
  let game:Game
  init() {
    let texture = Game.currentTrackSettings.distractorTexture
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
      border.strokeColor = Game.currentTrackSettings.borderColor
      border.lineWidth = 6
    }
    
    //alpha
    self.alpha = Game.currentTrackSettings.alpha
    
    self.size = CGSize(width: 40, height: 40)
    self.name = "ball-\(Ball.members.count + 1)"
    self.isUserInteractionEnabled = false
    //physics setup
    self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2 * 0.95)
    self.physicsBody?.isDynamic = true
    self.physicsBody?.allowsRotation = true
    self.physicsBody?.friction = 0
    self.physicsBody?.linearDamping = 0
    self.physicsBody?.angularDamping = 0
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
  
  func showBorder(){
    if let border = self.border { self.addChild(border) }
  }
  
  func hideBorder(){
    if let border = self.border { border.removeFromParent() }
  }
  
  func removeParticles(){
    for node in self.children {
      if node is SKEmitterNode { node.removeFromParent() }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    if self.foundTarget { return }
    if !currentGame.failedAttempt {
      if Ball.getTargets().contains(self) {
        currentGame.foundTargets += 1
        self.foundTarget = true
        Sensory.foundTargetsFeedback(foundTarget: self)
        DataStore.eventMarkers["didAttempt"] = ["flag": true, "success": true]
      }else{
        currentGame.failedAttempt = true
        currentGame.resetStatusBalls()
        Sensory.missedTargetFeedback()
        DataStore.eventMarkers["didAttempt"] = ["flag": true, "success": false]
        //irrelevant for now
        currentGame.missesRemaining -= 1
        print("miss!")
      }
    }else{
      Sensory.missedTargetFeedback()
      print("failed attempt")
    }
  }
}


