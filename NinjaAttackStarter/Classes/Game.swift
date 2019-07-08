
import Foundation
import SpriteKit

class Game {
  
  static var settingsArr:[Settings] = [
    Settings(phase: 1, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 1.5, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 650, targetSpeedSD: 375, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, phaseDuration: 70, pauseDelay: 15, pauseError: 4, pauseDuration: 2.5, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 500, targetSpeedSD: 275, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, phaseDuration: 80, pauseDelay: 22, pauseError: 6, pauseDuration: 4, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 375, targetSpeedSD: 175, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, phaseDuration: 100, pauseDelay: 30, pauseError: 6, pauseDuration: 5, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 275, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, phaseDuration: 120, pauseDelay: 35, pauseError: 8, pauseDuration: 6, frequency: 6, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 25, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-aqua", distractorTexture: "sphere-gray", flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 6, phaseDuration: 5, pauseDelay: 40, pauseError: 10, pauseDuration: 7, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 100, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-black", flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 7, phaseDuration: 180, pauseDelay: 40, pauseError: 10, pauseDuration: 7, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 100, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-black", flashTexture: "sphere-white", alpha: 1)
  ]
  

  static var currentSettings:Settings = settingsArr[5] {
    didSet {
      if let timer = currentGame.timer {
        print(currentGame.timer!.members)
        timer.stopTimer(timerID: "frequencyLoopTimer")
        Sensory.applyFrequency()
        timer.stopTimer(timerID: "targetTimer")
        timer.recursiveTargetTimer()
      }
      if Ball.getTargets().count < Game.currentSettings.numTargets && self.currentSettings.phase != 7 {
        let numTargets = Game.currentSettings.numTargets - Ball.getTargets().count
        for _ in 1...numTargets { Ball.addTarget()}
      }
      
      if self.currentSettings.phase == 7 {
        MotionControl.circleMovement(duration: 4)
      }
      
      if currentGame.isPaused {
        Ball.resetTextures()
        Ball.maskTargets()
      }else{
        Ball.resetTextures()
      }
      
      ///TESTING/////////

    }
  }
  
  class func advancePhase(){
    if let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentSettings.phase + 1 }), let timer = currentGame.timer {
      if index < self.settingsArr.count {
        self.currentSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }
      //TESTING
    }
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
    if let actionNode = self.world {
      for sprite in collection{
        actionNode.addChild(sprite)
      }
    }
  }

}

