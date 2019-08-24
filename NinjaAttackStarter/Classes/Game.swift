
import Foundation
import SpriteKit

class Game {
  
  static var settingsArr:[Settings] = [
    Settings(phase: 1, missesAllowed: 0, requiredStreak: 5, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2, frequency: 16, toneFile: "tone200hz.wav", targetMeanSpeed: 650, targetSpeedSD: 325, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, missesAllowed: 0, requiredStreak: 5,  phaseDuration: 70, pauseDelay: 15, pauseError: 4, pauseDuration: 3, frequency: 12, toneFile: "tone185hz.wav", targetMeanSpeed: 525, targetSpeedSD: 275, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, missesAllowed: 0, requiredStreak: 5, phaseDuration: 90, pauseDelay: 22, pauseError: 6, pauseDuration: 5, frequency: 9, toneFile: "tone170hz.wav", targetMeanSpeed: 400, targetSpeedSD: 175, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.cyan,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, missesAllowed: 0, requiredStreak: 4, phaseDuration: 120, pauseDelay: 30, pauseError: 6, pauseDuration: 6, frequency: 6, toneFile: "tone155hz.wav", targetMeanSpeed: 300, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 35, pauseError: 8, pauseDuration: 7, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 225, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, missesAllowed: 0, requiredStreak: 3, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, missesAllowed: 0, requiredStreak: 2, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 3.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]
  static var respSettingsArr:[RespSettings] = [
    RespSettings(phase: 7, frequency: 4, inDuration: 3.5, inWait: 1.5, outDuration: 5, outWait: 2.5, moveToCenterDuration: 8.5, moveCenterWait: 2)
  ]
  static var respActive:Bool = false
  static var initialRespTransition = true
  ///STARTING POINTS
  static var currentRespSettings:RespSettings = respSettingsArr[0]
  
  static var currentTrackSettings:Settings = settingsArr[0] {
   didSet {
    if self.currentTrackSettings.phase == 6 {
      //detection of final dummy phase (i.e,. phase '7') trips flag to begin transition into resp
      self.respActive = true
    }
    if let timer = currentGame.timer, let world = currentGame.world {
      if self.respActive {
        self.transitionRespPhase(timer: timer, world: world)
      }else{
        self.transitionTrackPhase(timer:timer)
      }
     }
    }
  }
  
  class func advancePhase(){
    if let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentTrackSettings.phase + 1 }), let timer = currentGame.timer {
      if !self.respActive && index < self.settingsArr.count {
        self.currentTrackSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }else{
        //do resp stuff here
        
      }
    }
  }
  
  class func transitionTrackPhase(timer:Timer){
    currentGame.streakAchieved = false
    currentGame.successHistory = [Bool]()
    currentGame.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
    for (_, node) in Sensory.audioNodes {
      node.run(SKAction.changeVolume(by: Float(-0.225), duration: 0))
    }
    Sensory.applyFrequency()
    timer.targetTimer()
    if Ball.getTargets().count < Game.currentTrackSettings.numTargets && self.currentTrackSettings.phase < 6 {
      let numTargets = Game.currentTrackSettings.numTargets - Ball.getTargets().count
      for _ in 1...numTargets { Ball.addTarget()}
    }
    for ball in Ball.members {
      ball.border?.strokeColor = currentTrackSettings.borderColor
    }
    Ball.resetTextures()
  }
  
  class func transitionRespPhase(timer:Timer, world:SKNode){

    Sensory.applyFrequency()
    let circleAction = SKAction.run({ timer.circleMovementTimer()})
    //for transition from trackphase only
    if self.initialRespTransition {
      timer.members.forEach({ loop in
        if loop != "frequencyLoopTimer" && loop != "gameTimer"  && loop != "movementTimer" {timer.stopTimer(timerID: loop)}
      })
      Ball.getTargets().forEach({ball in ball.flickerOutTarget()})
      
      //bleed speed and stop master movement timer prior to calling circleMovementTimer
      let bleedSpeed = SKAction.run {
        timer.bleedSpeedTimer()
      }
      let wait = SKAction.wait(forDuration: 5)
      let stopMovementTimer = SKAction.run({ timer.stopTimer(timerID: "movementTimer")})

      world.run(SKAction.sequence([bleedSpeed,wait,stopMovementTimer,wait,circleAction]))
    }else{
      world.run(SKAction.sequence([circleAction]))
    }
  }
  
  

  var gameScene:GameScene?
  var timer:Timer?
  var world:SKNode?
  
  var successHistory = [Bool]() {
    didSet {
      if successHistory.count >= Game.currentTrackSettings.requiredStreak {
        if !successHistory.dropFirst(successHistory.count - Game.currentTrackSettings.requiredStreak).contains(false) {
          self.streakAchieved = true
          if let gameScene = currentGame.gameScene {
            gameScene.run(SKAction.run({
              Sensory.audioNodes["streak"]?.run(SKAction.play())
            }))
          }
        }
      }
    }
  }
  //currently unused setting variable
  var missesRemaining = Game.currentTrackSettings.missesAllowed
  
  var foundTargets = 0 {
    didSet {
      if self.foundTargets == Game.currentTrackSettings.numTargets {
        currentGame.successHistory.append(true)
        for ball in currentGame.statusBalls {
          if ball.texture!.description == "<SKTexture> 'sphere-black' (256 x 256)" {
            ball.run(SKAction.setTexture(SKTexture(imageNamed: "sphere-yellow")))
            break
          }
        }
      }
    }
  }
  var streakAchieved = false
  var failedAttempt = false {
    didSet {
      if self.failedAttempt { self.successHistory.append(false)}
    }
  }
  
  var statusBalls = [SKSpriteNode]()
  
  var isPaused:Bool {
    didSet {
      isPaused == true ? Ball.enableInteraction() : Ball.disableInteraction()
    }
  }
  
  
  init(){
    self.isPaused = false
  }
  
  func setupGame(){
    self.timer = Timer()
    self.world = SKNode()
    if let scene = self.gameScene {
      if let world = self.world {
        scene.addChild(world)
        world.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
      }
      //gamescene formatting
      scene.backgroundColor = .white
      scene.scaleMode = .aspectFit
      scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
      scene.physicsWorld.gravity = .zero
      scene.physicsWorld.contactDelegate = gameScene
      
      if let correctSound = Sensory.audioNodes["correct"], let incorrectSound = Sensory.audioNodes["incorrect"], let streakSound = Sensory.audioNodes["streak"] {
        correctSound.autoplayLooped = false
        incorrectSound.autoplayLooped = false
        streakSound.autoplayLooped = false
        scene.addChild(correctSound)
        scene.addChild(incorrectSound)
        scene.addChild(streakSound)
      }
      self.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)

      //stimuli
      Ball.createBalls(num: 12, game: self)
      Tile.createTiles()
      self.addMemberstoScene(collections: [Ball.members, Tile.members])
    }
  }
  
  func startGame(){
    if let masterTimer = currentGame.timer {
      masterTimer.startGameTimer()
      Ball.startMovement()
      self.timer?.startTimerActions()
      Sensory.applyFrequency()
      //testing
    }
  }
  
  func pauseGame(){
    if !Ball.blinkFlags.isEmpty {
      Ball.pendingPause = true
      return
    }
    if let gameWorld = self.world, let timer = self.timer {
      gameWorld.isPaused = true
      self.isPaused = true
      Ball.freezeMovement()
      Ball.maskTargets()
      currentGame.foundTargets = 0
      currentGame.failedAttempt = false
      //irrelevant for now
      currentGame.missesRemaining = Game.currentTrackSettings.missesAllowed
      //
      timer.pauseCountdown()
      //testing
    }
  }
  
  
  func unpauseGame(){
    if let world = self.world {
      world.isPaused = false
      self.isPaused = false
      Ball.unfreezeMovement()
      Ball.unmaskTargets()
      Ball.hideBorders()
      Ball.resetTextures()
    }
  }
  
  func resetStatusBalls(){
    self.statusBalls.forEach({ ball in ball.run(SKAction.setTexture(SKTexture(imageNamed: "sphere-black")))})
  }
  
  
  
  private
  
  func addMemberstoScene(collections: [[SKNode]]){
    if let world = self.world {
      for collection in collections {
        for node in collection{
          world.addChild(node)
        }
      }
    }
  }
  
  func createStatusBalls(num:Int){
    self.statusBalls.forEach({ball in ball.removeFromParent()})
    self.statusBalls = [SKSpriteNode]()
    if let gameScene = currentGame.gameScene {
      for _ in 1...num {
        let xPosition = self.statusBalls.isEmpty ? gameScene.size.width / 15 : self.statusBalls.last!.position.x + 20
        let statusBall = SKSpriteNode(imageNamed: "sphere-black")
        statusBall.size = CGSize(width: 15, height: 15)
        statusBall.zPosition = -1
        statusBall.position.x = xPosition
        statusBall.position.y = gameScene.size.height / 9 * 8
        self.statusBalls.append(statusBall)
        gameScene.addChild(statusBall)
      }
    }
  }
}

