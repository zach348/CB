
import Foundation
import SpriteKit

class Game {
  
  static var settingsArr:[Settings] = [
    Settings(phase: 1, missesAllowed: 0, requiredStreak: 3, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2.5, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 600, targetSpeedSD: 300, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, missesAllowed: 0, requiredStreak: 3,  phaseDuration: 70, pauseDelay: 14, pauseError: 4, pauseDuration: 4, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 500, targetSpeedSD: 225, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, missesAllowed: 0, requiredStreak: 3, phaseDuration: 90, pauseDelay: 18, pauseError: 4, pauseDuration: 5, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 400, targetSpeedSD: 150, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.cyan,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 21, pauseError: 5, pauseDuration: 6, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 300, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 24, pauseError: 6, pauseDuration: 8, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 200, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, missesAllowed: 0, requiredStreak: 3, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, missesAllowed: 0, requiredStreak: 2, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 2.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]
  static var respSettingsArr:[RespSettings] = [
    RespSettings(phase: 7, phaseDuration: 60, frequency: 4, inDuration: 4, inWait: 2, outDuration: 8, outWait: 3, moveToCenterDuration: 8.5, moveCenterWait: 2),
    RespSettings(phase: 8, phaseDuration: 120, frequency: 3.5, inDuration: 5, inWait: 3, outDuration: 10, outWait: 4.5, moveToCenterDuration: 8.5, moveCenterWait: 2),
    RespSettings(phase: 9, phaseDuration: 999, frequency: 3, inDuration: 6, inWait: 4, outDuration: 12, outWait: 6, moveToCenterDuration: 10, moveCenterWait: 2)
  ]
  static var willSaveGame:Bool = false
  static var didSaveGame:Bool = false
  static var respActive:Bool = false
  static var initialRespTransition = true
  ///STARTING POINTS
  static var currentRespSettings:RespSettings = respSettingsArr[0] {
    didSet {
      currentGame.advanceRespFlag = true
    }
  }
  static var currentTrackSettings:Settings = settingsArr[0] {
    didSet {
      //detection of final dummy phase (i.e,. phase '7') trips flag to begin transition into resp
      if self.currentTrackSettings.phase == 6 {
        self.respActive = true
        print("printing", Game.respActive)
      }
      if let timer = currentGame.timer, let worldTimer = currentGame.worldTimer {
        if self.respActive {
          self.transitionRespPhase(timer: timer, initial: true, worldTimer: worldTimer)
        }else{
          self.transitionTrackPhase(timer:timer)
        }
      }
    }
  }
  
  class func advancePhase(){
    guard let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentTrackSettings.phase + 1 }), let timer = currentGame.timer else {return}
      if !self.respActive && index < self.settingsArr.count {
        self.currentTrackSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }else if self.respActive{
        //do resp stuff here
        guard let respIndex = self.respSettingsArr.firstIndex(where: { respSetting in respSetting.phase == self.currentRespSettings.phase + 1 }) else { return }
        self.currentRespSettings = self.respSettingsArr[respIndex]
        timer.lastPhaseShiftTime = timer.elapsedTime
        if Game.currentRespSettings.phase == 8 { Sensory.fadeScreen() }
        print("Advanced resp phase")
      }
    
  }
  
  class func transitionTrackPhase(timer:Timer){
    currentGame.streakAchieved = false
    currentGame.successHistory = [Bool]()
    currentGame.streakLength = 0
    currentGame.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
    
    for (_, node) in Sensory.audioNodes {
      node.run(SKAction.changeVolume(by: Float(-0.3), duration: 0))
    }
    Sensory.applyFrequency()
    if(Game.currentTrackSettings.phase < 5){
      timer.targetTimer()
    }else{
      timer.stopTimer(timerID: "targetTimer")
    }
    if Ball.getTargets().count < Game.currentTrackSettings.numTargets && self.currentTrackSettings.phase < 6 {
      let numTargets = Game.currentTrackSettings.numTargets - Ball.getTargets().count
      for _ in 1...numTargets { Ball.addTarget()}
    }
    for ball in Ball.members {
      ball.border?.strokeColor = currentTrackSettings.borderColor
    }
    Ball.resetTextures()
    
    
    //testing
    
    //saving
    
  }
  
  class func transitionRespPhase(timer:Timer, initial:Bool = false, worldTimer:SKNode){
    //Remove phase advancement flag
    currentGame.advanceRespFlag = false
    //Refresh Frequency
    Sensory.applyFrequency()

    let circleAction:SKAction = initial ? SKAction.run({ timer.circleMovementTimer(initial: true)}) : SKAction.run({ timer.circleMovementTimer(initial: false)})
    //for transition from trackphase only
    if self.initialRespTransition {
      //Cleanup
      timer.members.forEach({ loop in
        if loop != "frequencyLoopTimer" && loop != "gameTimer"  && loop != "movementTimer" {timer.stopTimer(timerID: loop)}
      })
      for ball in Ball.getTargets(){
        Sensory.flickerOffTexture(sprite: ball, onTexture: Game.currentTrackSettings.targetTexture, offTexture: Game.currentTrackSettings.distractorTexture)
      }
      
      for statusBall in currentGame.statusBalls {
        Sensory.flickerOffAlpha(sprite: statusBall, startingAlpha: statusBall.alpha, endingAlpha: 0)
      }
      
      //Prep
      timer.breathLabel.fontColor = SKColor.black
      timer.breathLabel.fontSize = 30
      timer.breathLabel.fontName = "AvenirNext-Bold"
      timer.breathLabel.position.x = currentGame.gameScene!.size.width / 2
      timer.breathLabel.position.y = currentGame.gameScene!.size.height / 2
      timer.breathLabel.zPosition = -0.50
      if let gameScene = currentGame.gameScene { gameScene.addChild(timer.breathLabel)}
      Sensory.prepareHaptics()
      
      //bleed speed and stop master movement timer prior to calling circleMovementTimer
      let bleedSpeed = SKAction.run {
        timer.bleedSpeedTimer()
      }
      let wait = SKAction.wait(forDuration: 5)
      let stopMovementTimer = SKAction.run({ timer.stopTimer(timerID: "movementTimer")})
      self.initialRespTransition = false
      worldTimer.run(SKAction.sequence([bleedSpeed,wait,stopMovementTimer,wait,circleAction]))
    }else{
      print("running non initial circleaction")
      worldTimer.run(SKAction.sequence([circleAction]))
    }
  }
  
  
  
  var gameScene:GameScene?
  var timer:Timer?
  var worldTimer:SKNode?
  var spriteWorld:SKNode?
  var hrController:HRMViewController?
  var statusBalls = [SKSpriteNode]()
  //currently unused setting variable
  var missesRemaining = Game.currentTrackSettings.missesAllowed
  var advanceRespFlag:Bool = false
  var successHistory = [Bool]() {
    didSet {
      if successHistory.count >= Game.currentTrackSettings.requiredStreak {
        if !successHistory.dropFirst(successHistory.count - Game.currentTrackSettings.requiredStreak).contains(false) {
          self.streakAchieved = true
        }
      }
    }
  }
  var foundTargets = 0 {
    didSet {
      if self.foundTargets == Game.currentTrackSettings.numTargets {
        currentGame.successHistory.append(true)
      }
    }
  }
  var streakAchieved = false {
    didSet {
      if self.streakAchieved {
        Sensory.streakAchievedFeedback()
      }
    }
  }
  var failedAttempt = false {
    didSet {
      if self.failedAttempt { self.successHistory.append(false)}
    }
  }
  
  var streakLength = 0
  var isPaused:Bool {
    didSet {
      if let worldTimer = currentGame.worldTimer {
        if isPaused {
          Ball.enableInteraction()
          worldTimer.isPaused = true
        }else{
          Ball.disableInteraction()
          worldTimer.isPaused = false
        }
      }
    }
  }
  
  var bpm:Int = -1
  
  init(){
    self.isPaused = false
  }
  
  func setupGame(){
    self.timer = Timer()
    self.worldTimer = SKNode()
    self.spriteWorld = SKNode()
    self.hrController = HRMViewController()
    DataStore.dummyRequest()
    
    if let scene = self.gameScene {
      if let worldTimer = self.worldTimer, let spriteWorld = currentGame.spriteWorld {
        scene.addChild(worldTimer)
        scene.addChild(spriteWorld)
        spriteWorld.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
      }
      //gamescene formatting
      scene.backgroundColor = .white
      scene.scaleMode = .aspectFit
      scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
      scene.physicsWorld.gravity = .zero
      scene.physicsWorld.contactDelegate = gameScene
      
      for (name, audioNode) in Sensory.audioNodes {
        audioNode.autoplayLooped = false
        if name == "blip" {audioNode.run(SKAction.changeVolume(by: -0.6, duration: 0))}
        scene.addChild(audioNode)
      }
      
      self.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
      
      //stimuli
      self.gameScene!.view!.frame.width < 670 ? Ball.createBalls(num: 10, game: self) : Ball.createBalls(num: 12, game: self)
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
    }
  }
  
  func pauseGame(){
    
    
    //implementation
    if !Ball.blinkFlags.isEmpty {
      Ball.pendingPause = true
      return
    }
    if let timer = self.timer {
      self.isPaused = true
      Ball.freezeMovement()
      Ball.maskTargets()
      Ball.resetFoundTargets()
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
    self.isPaused = false
    Ball.removeEmitters()
    Ball.unfreezeMovement()
    Ball.unmaskTargets()
    Ball.hideBorders()
    Ball.resetTextures()
  }
  
  func resetStatusBalls(){
    self.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
  }
  
  func incrementStatusBalls(emitter:Bool = false) {
    self.streakLength += 1
    for ball in self.statusBalls {
      if ball.texture!.description == "<SKTexture> 'sphere-black' (256 x 256)" {
        ball.run(SKAction.setTexture(SKTexture(imageNamed: "sphere-yellow")))
        if emitter { Sensory.addParticles(sprite: ball, emitterFile: "ball_fire")}
        return
      }
    }
  }
  
  private
  
  func addMemberstoScene(collections: [[SKNode]]){
    if let spriteWorld = self.spriteWorld {
      for collection in collections {
        for sprite in collection{
          spriteWorld.addChild(sprite)
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

