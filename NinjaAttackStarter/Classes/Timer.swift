
import Foundation
import SpriteKit

class Timer {
  var members:[String]
  var elapsedTime:Double = 0 {
    didSet {
      if Ball.blinkFlags.isEmpty {
        self.remainingInPhase = Game.currentTrackSettings.phaseDuration - (self.elapsedTime - self.lastPhaseShiftTime)
        if self.remainingInPhase <  0 && !currentGame.isPaused { Game.advancePhase() }
      }
    }
  }
  var lastPhaseShiftTime:Double
  var remainingInPhase:Double
  init(){
    self.members = []
    self.lastPhaseShiftTime = 0
    self.remainingInPhase = Game.currentTrackSettings.phaseDuration
    currentGame.timer = self
  }
  
  func startGameTimer(){
    let wait = SKAction.wait(forDuration: 0.05)
    let count = SKAction.run {
      self.elapsedTime += 0.05
    }
  //Master Game block kept at top level/ on gamescene instance
    if let scene = currentGame.gameScene {
      self.members.append("gameTimer")
      scene.run(SKAction.repeatForever(SKAction.sequence([wait,count])), withKey: "gameTimer")
    }
  }

  func movementTimer(){
    if let gameWorld = currentGame.world {
      let wait = SKAction.wait(forDuration: 0.05)
      let correctMovement = SKAction.run {
        MotionControl.correctMovement()
      }
      self.members.append("movementTimer")
      gameWorld.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
    }
  }
  
  func bleedSpeedTimer(){
    if let gameWorld = currentGame.world {
      let wait = SKAction.wait(forDuration: 0.05)
      let correctMovement = SKAction.run {
        MotionControl.bleedSpeed()
      }
      self.members.append("movementTimer")
      gameWorld.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
    }
  }
  
  func circleMovementTimer(){
    let concentrics = MotionControl.generateConcentrics()
    for index in 0..<Ball.members.count {
      let ball = Ball.members[index], incrementalOutDuration = Game.currentRespSettings.outDuration/4, incrementalInDuration = Game.currentRespSettings.inDuration/4
      var inActions = [SKAction](), outActions = [SKAction](), trajectory = [CGPoint](), legIndices = [Int]()
      for pointsIndex in stride(from: 0, through: concentrics.count - 1, by: 2){
        let point = concentrics[pointsIndex][index]
        trajectory.append(point)
      }
      legIndices.append((trajectory.count - 1) / 10 * 4)
      legIndices.append((trajectory.count - 1) / 10 * 7)
      legIndices.append((trajectory.count - 1) / 10 * 9)
      legIndices.append(trajectory.count - 1)
      
      for legIndex in legIndices {
        inActions.append(SKAction.move(to: trajectory[legIndex], duration: incrementalInDuration))
        outActions.append(SKAction.move(to: trajectory.reversed()[legIndex], duration: incrementalOutDuration))
      }
      let moveOutSequence = SKAction.sequence(outActions)
      let moveInSequence = SKAction.sequence(inActions)
      let moveInWait = SKAction.wait(forDuration: Game.currentRespSettings.inWait)
      let moveOutWait = SKAction.wait(forDuration: Game.currentRespSettings.outWait)
      let moveToCenter = SKAction.move(to: trajectory.first!, duration: Game.currentRespSettings.moveToCenterDuration)
      let moveToCenterWait = SKAction.wait(forDuration: Game.currentRespSettings.moveCenterWait)
      let centerSequence = SKAction.sequence([moveToCenter,moveToCenterWait])
      let finalSequence = SKAction.repeatForever(SKAction.sequence([moveInSequence,moveInWait,moveOutSequence,moveOutWait]))
      self.members.append("breathLoop")
      ball.run(SKAction.sequence([centerSequence,finalSequence]), withKey: "breathLoop")
      //create a speed bleed/transition function
      ball.physicsBody?.velocity.dx = 0
      ball.physicsBody?.velocity.dy = 0
    }
  }
  
  func recursivePauseTimer(){
    if let gameScene = currentGame.gameScene {
      gameScene.removeAction(forKey: "pauseTimer")
      self.members = self.members.filter({ $0 != "pauseTimer"})
      let error = Game.currentTrackSettings.pauseError
      let wait = SKAction.wait(forDuration: (Double.random(min: Game.currentTrackSettings.pauseDelay - error, max: Game.currentTrackSettings.pauseDelay + error)))
      let pause = SKAction.run { currentGame.pauseGame()}
      let sequence = SKAction.sequence([wait, pause])
      
      self.members.append("pauseTimer")
      gameScene.run(sequence, withKey: "pauseTimer")
    }
  }
  
  func pauseCountdown(){
    if let gameScene = currentGame.gameScene {
      gameScene.removeAction(forKey: "unpauseTimer")
      self.members = self.members.filter({ $0 != "unpauseTimer"})
      let unpauseWait = SKAction.wait(forDuration: Game.currentTrackSettings.pauseDuration)
      let unpause = SKAction.run { currentGame.unpauseGame()}
      let recursiveCall = SKAction.run {
        self.recursivePauseTimer()
      }
      let countdown = SKAction.run {
        self.pauseCountdownTimer(pauseDuration: unpauseWait.duration)
      }
      self.members.append("unpauseTimer")
      let countGroup = SKAction.group([unpauseWait, countdown])
      let unpauseGroup = SKAction.group([unpause, recursiveCall])
      let sequence = SKAction.sequence([countGroup, unpauseGroup])
      gameScene.run(sequence, withKey: "unpauseTimer")
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
      self.stopTimer(timerID: "targetTimer")
      let error = Game.currentTrackSettings.shiftError
      let wait = SKAction.wait(forDuration: (Double.random(min: Game.currentTrackSettings.shiftDelay - error, max: Game.currentTrackSettings.shiftDelay + error)))
      let shift = SKAction.run {
        Ball.shiftTargets()
        print("SHIFTTARGETS")
        print("Delay " + String(wait.duration))
        print("Setting Value: " + String(Game.currentTrackSettings.shiftDelay))
      }
      self.members.append("targetTimer")
      gameWorld.run(SKAction.sequence([wait, shift]), withKey: "targetTimer")
    }
  }
  
  func stopTimer(timerID:String) {
    if let gameWorld = currentGame.world, let scene = currentGame.gameScene  {
      if timerID == "gameTimer" || timerID == "frequencyLoopTimer" || timerID == "pauseTimer" {
        self.members = self.members.filter { $0 != timerID }
        scene.removeAction(forKey: timerID)
      }else{
        gameWorld.removeAction(forKey: timerID)
        self.members = self.members.filter { $0 != timerID }
      }
    }
  }
  
  
  func startTimerActions(){
    self.movementTimer()
    self.recursiveTargetTimer()
    self.recursivePauseTimer()
  }
}
