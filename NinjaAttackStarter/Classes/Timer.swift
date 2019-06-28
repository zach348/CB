
import Foundation
import SpriteKit

class Timer {
  var members:[String]
  var elapsedTime:Double = 0 {
    didSet {
      if !Ball.blinkFlag {
        self.remainingInPhase = Game.currentSettings.phaseDuration - (self.elapsedTime - self.lastPhaseShiftTime)
        if self.remainingInPhase <  0 { Game.advancePhase() }
      }
    }
  }
  var lastPhaseShiftTime:Double
  var remainingInPhase:Double
  init(){
    self.members = []
    self.lastPhaseShiftTime = 0
    self.remainingInPhase = Game.currentSettings.phaseDuration
    currentGame.timer = self
  }
  
  func startGameTimer(){
    let wait = SKAction.wait(forDuration: 0.025)
    let count = SKAction.run {
      self.elapsedTime += 0.025
    }
  //Master Game block kept at top level/ on gamescene instance
    if let scene = currentGame.gameScene {
      self.members.append("gameTimer")
      scene.run(SKAction.repeatForever(SKAction.sequence([wait,count])), withKey: "gameTimer")
    }
  }
  
  //other timers on world node
  func startMovementTimer(){
    if let gameWorld = currentGame.world {
      let wait = SKAction.wait(forDuration: 0.1)
      let correctMovement = SKAction.run {
        MotionControl.correctMovement()
      }
      self.members.append("movementTimer")
      gameWorld.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
    }
  }
  
  func recursivePauseTimer(){
    //pausing loop
    if let gameScene = currentGame.gameScene {
      gameScene.removeAction(forKey: "pauseTimer")
      self.members = self.members.filter({ $0 != "pauseTimer"})
      //pause delay
      let error = Game.currentSettings.pauseError
      let wait = SKAction.wait(forDuration: (Double.random(min: Game.currentSettings.pauseDelay - error, max: Game.currentSettings.pauseDelay + error)))
      let unpauseWait = SKAction.wait(forDuration: Game.currentSettings.pauseDuration)
      let pause = SKAction.run { currentGame.pauseGame()}
      let unpause = SKAction.run { currentGame.unpauseGame()}
      let recursiveCall = SKAction.run {
        self.recursivePauseTimer()
      }
      let countdown = SKAction.run {
        self.pauseCountdownTimer(pauseDuration: unpauseWait.duration)
      }
      self.members.append("pauseTimer")
      
      let countGroup = SKAction.group([unpauseWait, countdown])
      let unpauseGroup = SKAction.group([unpause, recursiveCall])
      let sequence = SKAction.sequence([wait, pause, countGroup, unpauseGroup])
      gameScene.run(sequence)
    }
  }
  
  func pauseCountdownTimer(pauseDuration:Double){
    if let gameScene = currentGame.gameScene {
      var timerNode: Double = pauseDuration
      let timerLabel = SKLabelNode()
      timerLabel.text = "\(String(format: "%.3f", timerNode))"
      timerLabel.fontColor = SKColor.black
      timerLabel.fontSize = 40
      timerLabel.position.x = gameScene.size.width / 2
      timerLabel.position.y = gameScene.size.height / 8.5
      timerLabel.zPosition = 3.00
      gameScene.addChild(timerLabel)
      
      let loop = SKAction.repeatForever(SKAction.sequence([SKAction.run {
        timerNode -= 0.1
        timerLabel.text = "\(String(format: "%.1f", timerNode))"
        if timerNode <= 0 {
          timerLabel.removeFromParent()
          gameScene.removeAction(forKey: "pauseDurationTimer")
        }
        },SKAction.wait(forDuration: 0.1)]))
      gameScene.run(loop, withKey: "pauseDurationTimer")
    }
  }
  
  func recursiveTargetTimer() {
    if let gameWorld = currentGame.world {
      gameWorld.removeAction(forKey: "targetTimer")
      self.members = self.members.filter({ $0 != "targetTimer"})
      //let wait = SKAction.wait(forDuration: Game.currentSettings.shiftDelay, withRange: Game.currentSettings.shiftError)
      let error = Game.currentSettings.shiftError
      let wait = SKAction.wait(forDuration: (Double.random(min: Game.currentSettings.shiftDelay - error, max: Game.currentSettings.shiftDelay + error)))
      let shift = SKAction.run {
        Ball.shiftTargets()
      }
      let recursiveCall = SKAction.run {
        self.recursiveTargetTimer()
      }
      self.members.append("targetTimer")
      gameWorld.run(SKAction.sequence([wait, shift, recursiveCall]), withKey: "targetTimer")
    }
  }
  
  func stopTimer(timerID:String) {
    if let world = currentGame.world, let scene = currentGame.gameScene  {
      if timerID == "gameTimer" || timerID == "frequencyLoopTimer" {
        self.members = self.members.filter { $0 != timerID }
        scene.removeAction(forKey: timerID)
      }else{
        world.removeAction(forKey: timerID)
        self.members = self.members.filter { $0 != timerID }
      }
    }
  }
  
  
  func startTimerActions(){
    self.startMovementTimer()
    self.recursiveTargetTimer()
    self.recursivePauseTimer()
  }
}
