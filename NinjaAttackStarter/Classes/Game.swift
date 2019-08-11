
import Foundation
import SpriteKit

class Game {
  
  static var settingsArr:[Settings] = [
    Settings(phase: 1, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 550, targetSpeedSD: 325, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.red, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, phaseDuration: 70, pauseDelay: 15, pauseError: 4, pauseDuration: 3, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 475, targetSpeedSD: 275, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.red, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, phaseDuration: 90, pauseDelay: 22, pauseError: 6, pauseDuration: 5, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 375, targetSpeedSD: 175, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.red,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, phaseDuration: 120, pauseDelay: 30, pauseError: 6, pauseDuration: 6, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 250, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, phaseDuration: 120, pauseDelay: 35, pauseError: 8, pauseDuration: 7, frequency: 6, toneFile: "tone140hz.wav", targetMeanSpeed: 200, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 3.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]
  static var respSettingsArr:[RespSettings] = [
    RespSettings(phase: 7, frequency: 4, inDuration: 3.5, inWait: 1.5, outDuration: 5, outWait: 2.5, moveToCenterDuration: 8.5, moveCenterWait: 2)
  ]
  static var respTransition:Bool = false
  ///STARTING POINTS
  static var currentRespSettings:RespSettings = respSettingsArr[0]
  
  static var currentTrackSettings:Settings = settingsArr[0] {
   didSet {
    if self.currentTrackSettings.phase == 6 {
      //detection of final dummy phase (i.e,. phase '7') trips flag to begin transition into resp
      self.respTransition = true
    }
    if let timer = currentGame.timer, let world = currentGame.world {
      if !self.respTransition {
        self.transitionTrackPhase(timer:timer)
      }else{
        self.transitionRespPhase(timer: timer, world: world)
      }
     }
    }
  }
  
  class func advancePhase(){
    if let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentTrackSettings.phase + 1 }), let timer = currentGame.timer {
      if !self.respTransition && index < self.settingsArr.count {
        self.currentTrackSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }else{
        //do resp stuff here
        
      }
    }
  }
  
  class func transitionTrackPhase(timer:Timer){
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
    timer.members.forEach({ loop in
      if loop != "frequencyLoopTimer" && loop != "gameTimer"  && loop != "movementTimer" {timer.stopTimer(timerID: loop)}
    })
    Sensory.applyFrequency(frequency: Game.currentRespSettings.frequency)
    //flicker effect
    Ball.getTargets().forEach({ball in ball.flickerOutTarget()})
    //bleed speed and stop master movement timer prior to calling circleMovementTimer
    let bleedSpeed = SKAction.run {
      timer.bleedSpeedTimer()
    }
    let wait = SKAction.wait(forDuration: 5)
    let stopMovementTimer = SKAction.run({ timer.stopTimer(timerID: "movementTimer")})
    let circleAction = SKAction.run({ timer.circleMovementTimer()})
    world.run(SKAction.sequence([bleedSpeed,wait,stopMovementTimer,wait,circleAction]))
  }
  
  

  var gameScene:GameScene?
  var timer:Timer?
  var world:SKNode?
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
      
      //stimuli
      Ball.createBalls(num: 12, game: self)
      self.addMemberstoScene(collection: Ball.members)
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
  
  func addMemberstoScene(collection: [SKSpriteNode]){
    if let world = self.world {
      for sprite in collection{
        world.addChild(sprite)
      }
      Tile.createTiles()
      for tile in Tile.members {
        world.addChild(tile)
      }
    }
  }

}

