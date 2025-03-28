
import Foundation
import SpriteKit
import CoreHaptics

class Timer {
  var members:[String]
  var elapsedTime:Double = 0 {
    didSet {
      if Ball.blinkFlags.isEmpty {
        //play mode
        if !Game.respActive && !currentGame.isPaused && currentGame.streakAchieved {
          self.remainingInPhase = Game.currentTrackSettings.phaseDuration - (self.elapsedTime - self.lastPhaseShiftTime)
          Game.advancePhase()
        } else if Game.respActive {
          self.remainingInPhase = Game.currentRespSettings.phaseDuration - (self.elapsedTime - self.lastPhaseShiftTime)
          if self.remainingInPhase < 0 {
            Game.advancePhase()
          }
          print(self.remainingInPhase)
        }
        //demo mode
//      if (!currentGame.isPaused && self.elapsedTime - self.lastPhaseShiftTime > 45) { Game.advancePhase()}
      }
    }
  }
  var lastPhaseShiftTime:Double = 0
  var remainingInPhase:Double
  var breathLabel:SKLabelNode = SKLabelNode(text: "")
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
    if let worldTimer = currentGame.worldTimer {
      let wait = SKAction.wait(forDuration: 0.025)
      let correctMovement = SKAction.run {
        MotionControl.correctMovement()
      }
      self.members.append("movementTimer")
      worldTimer.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
    }
  }
  
  func bleedSpeedTimer(loopDelay:Double = 0.05, factor:CGFloat = 0.99, factorError:CGFloat = 0.02){
    if let worldTimer = currentGame.worldTimer, let timer = currentGame.timer {
      let wait = SKAction.wait(forDuration: 0.05)
      let correctMovement = SKAction.run {
        for ball in Ball.members {
          ball.modifySpeed(factor: CGFloat.random(min: factor-0.02, max: factor))
        }
        if Ball.mean() < 30 { timer.stopTimers(timerArray: ["movementTimer"])}
      }
      self.members.append("movementTimer")
      worldTimer.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
    }
  }
  
  func circleMovementTimer(initial:Bool = false){
    guard let timer = currentGame.timer, let worldTimer = currentGame.worldTimer else { return }
    let concentrics = MotionControl.generateConcentrics()
    for index in 0..<Ball.members.count {
      let ball = Ball.members[index], incrementalOutDuration = Game.currentRespSettings.outDuration/4, incrementalInDuration = Game.currentRespSettings.inDuration/4
      var breathInActions = [SKAction](), breathOutActions = [SKAction](), trajectory = [CGPoint](), legIndices = [Int]()
      for pointsIndex in stride(from: 0, through: concentrics.count - 1, by: 2){
        let point = concentrics[pointsIndex][index]
        trajectory.append(point)
      }
      legIndices.append((trajectory.count - 1) / 10 * 4)
      legIndices.append((trajectory.count - 1) / 10 * 7)
      legIndices.append((trajectory.count - 1) / 10 * 9)
      legIndices.append(trajectory.count - 1)
      
      for legIndex in legIndices {
        let breathInMoveAction = SKAction.move(to: trajectory[legIndex], duration: incrementalInDuration)
        let breathOutMMoveAction = SKAction.move(to: trajectory.reversed()[legIndex], duration: incrementalOutDuration)
        
        breathInActions.append(SKAction.group([breathInMoveAction]))
        breathOutActions.append(SKAction.group([breathOutMMoveAction]))
      }
      
    
      
      let breathInBlock = SKAction.run {
        self.breathLabel.text = "Inhale"
        if Sensory.hapticsRunning {
          do {
            try Sensory.hapticPlayers["testIn\(Game.currentRespSettings.phase)"]?.start(atTime: 0)
          }catch{
            print("failed to play haptic pattern: \(error.localizedDescription)")
          }
        }
      }
      let breathInHoldBlock = SKAction.run {
        self.breathLabel.text = "Hold"
        if Sensory.hapticsRunning {
          do {
            try Sensory.hapticPlayers["testHold\(Game.currentRespSettings.phase)"]?.start(atTime: 0)
          }catch{
            print("failed to play haptic pattern: \(error.localizedDescription)")
          }
        }
      }
      let breathOutBlock = SKAction.run {
        self.breathLabel.text = "Exhale"
        if Sensory.hapticsRunning {
          do {
            try Sensory.hapticPlayers["testOut\(Game.currentRespSettings.phase)"]?.start(atTime: 0)
          }catch{
            print("failed to play haptic pattern: \(error.localizedDescription)")
          }
        }
      }
      
      let breathOutHoldBlock = SKAction.run{
        self.breathLabel.text = "Hold"
      }
      
      let breathOutSequence = SKAction.sequence(breathOutActions)
      let breathOutGroup = SKAction.group([breathOutSequence,breathOutBlock])
      let breathInSequence = SKAction.sequence(breathInActions)
      let breathInGroup = SKAction.group([breathInSequence,breathInBlock])
      let breathInWait = SKAction.wait(forDuration: Game.currentRespSettings.inWait)
      let breathInWaitGroup = SKAction.group([breathInWait,breathInHoldBlock])
      let breathOutWait = SKAction.wait(forDuration: Game.currentRespSettings.outWait)
      let breathOutWaitGroup = SKAction.group([breathOutWait,breathOutHoldBlock])
      let checkForPhaseAdv = SKAction.run {
        if currentGame.advanceRespFlag {
          self.stopTimers(timerArray: ["breathLoop"])
          for (key, player) in Sensory.hapticPlayers {
            do {
              try player.stop(atTime: 0)
            }catch{
              print("\(key) player failed to stop: \(error.localizedDescription)")
            }
          }
          Game.transitionRespPhase(timer: timer, worldTimer: worldTimer)
        }
      }
      let moveToCenter = SKAction.move(to: trajectory.first!, duration: Game.currentRespSettings.moveToCenterDuration)
      let moveToCenterGroup = SKAction.group([moveToCenter])
      let moveToCenterWait = SKAction.wait(forDuration: Game.currentRespSettings.moveCenterWait)
      let centerSequence = SKAction.sequence([moveToCenterGroup,moveToCenterWait])
      let finalSequence = SKAction.repeatForever(SKAction.sequence([breathInGroup,breathInWaitGroup,breathOutGroup,breathOutWaitGroup,checkForPhaseAdv]))
      self.members.append("breathLoop")
      
      if initial {
        ball.run(SKAction.sequence([centerSequence,finalSequence]), withKey: "breathLoop")
      }else{
        ball.run(finalSequence, withKey: "breathLoop")
      }
      //create a speed bleed/transition function
      ball.physicsBody?.velocity.dx = 0
      ball.physicsBody?.velocity.dy = 0
    }
  }
  
  func pauseTimer(){
    if let gameScene = currentGame.gameScene {
      self.stopTimers(timerArray: ["pauseTimer"])
      let error = Game.currentTrackSettings.pauseError
      let wait = SKAction.wait(forDuration: (Double.random(min: Game.currentTrackSettings.pauseDelay - error, max: Game.currentTrackSettings.pauseDelay + error)))
      let pause = SKAction.run { currentGame.beginAttempt()}
      let sequence = SKAction.sequence([wait, pause])
      
      self.members.append("pauseTimer")
      gameScene.run(sequence, withKey: "pauseTimer")
    }
  }
  
  func pauseCountdown(){
    if let gameScene = currentGame.gameScene {
      self.stopTimers(timerArray: ["unpauseTimer"])
      let unpauseWait = SKAction.wait(forDuration: Game.currentTrackSettings.pauseDuration)
      let unpause = SKAction.run { currentGame.endAttempt()}
      let recursiveCall = SKAction.run {
        self.pauseTimer()
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
      currentGame.pauseCountdownTimerLabel.text = "\(String(format: "%.3f", timerNode))"
      currentGame.pauseCountdownTimerLabel.fontColor = SKColor.black
      currentGame.pauseCountdownTimerLabel.fontSize = 40
      currentGame.pauseCountdownTimerLabel.fontName = "AvenirNext-Bold"
      currentGame.pauseCountdownTimerLabel.position.x = gameScene.size.width / 2
      currentGame.pauseCountdownTimerLabel.position.y = gameScene.size.height / 8.5
      currentGame.pauseCountdownTimerLabel.zPosition = -0.50
      gameScene.addChild(currentGame.pauseCountdownTimerLabel)
      
      var unpauseFlag = false
      let loop = SKAction.repeatForever(SKAction.sequence([SKAction.run {
        timerNode -= 0.1
        currentGame.pauseCountdownTimerLabel.text = "\(String(format: "%.1f", timerNode))"
        if timerNode <= 0 || currentGame.foundTargets == Game.currentTrackSettings.numTargets || currentGame.failedAttempt {
          currentGame.pauseCountdownTimerLabel.removeFromParent()
        }
        if (currentGame.foundTargets == Game.currentTrackSettings.numTargets || currentGame.failedAttempt) && !unpauseFlag {
          let unpause = SKAction.run { currentGame.endAttempt()}
          let pauseTimerCall = SKAction.run { self.pauseTimer()}
          let stopTimers = SKAction.run { self.stopTimers(timerArray: ["pauseDurationTimer", "unpauseTimer"])}
          let wait = SKAction.wait(forDuration: 0.5)
          let sequence = SKAction.sequence([wait,stopTimers,unpause,pauseTimerCall])
          gameScene.run(sequence)
          unpauseFlag = true
        }
      },SKAction.wait(forDuration: 0.1)]))
      self.members.append("pauseDurationTimer")
      gameScene.run(loop, withKey: "pauseDurationTimer")
    }
  }
  
  func targetTimer(){
    if let worldTimer = currentGame.worldTimer {
      self.stopTimers(timerArray: ["targetTimer"])
      let error = Game.currentTrackSettings.shiftError
      let duration = (Double.random(min: Game.currentTrackSettings.shiftDelay - error, max: Game.currentTrackSettings.shiftDelay + error))
      let wait = SKAction.wait(forDuration: duration )
      let shift = SKAction.run {
        Ball.shiftTargets()
        DataStore.eventMarkers["didShift"] = [
          "status": true,
          "delay": duration
        ]
      }
      self.members.append("targetTimer")
      worldTimer.run(SKAction.sequence([wait, shift]), withKey: "targetTimer")
    }
  }
  
  func dataTimer(){
    if let scene = currentGame.gameScene {
      self.stopTimers(timerArray: ["dataTimer"])
      let wait = SKAction.wait(forDuration: 0.5)
      let addRecord = SKAction.run {
        DataStore.addRecord()
      }
      self.members.append("dataTimer")
      scene.run(SKAction.sequence([wait,addRecord]), withKey: "dataTimer")
    }
  }
  
  func saveTimer(){
    if let scene = currentGame.gameScene {
      self.stopTimers(timerArray: ["saveTimer"])
      let wait = SKAction.wait(forDuration: 1)
      let saveRecords = SKAction.run {
        DataStore.saveRecords()
      }
      self.members.append("saveTimer")
      scene.run(SKAction.sequence([wait,saveRecords]), withKey: "saveTimer")
    }
  }
  
  func stopTimers(timerArray:[String]) {
    for timerID in timerArray {
      if let worldTimer = currentGame.worldTimer, let scene = currentGame.gameScene  {
        if timerID == "gameTimer" || timerID == "frequencyLoopTimer" || timerID == "pauseTimer" || timerID == "dataTimer" || timerID == "saveTimer" || timerID == "pauseTimer" || timerID == "unpauseTimer" || timerID == "pauseDurationTimer" {
          self.members = self.members.filter { $0 != timerID }
          scene.removeAction(forKey: timerID)
        }else if timerID == "breathLoop" {
          Ball.members.forEach { ball in
            ball.removeAction(forKey: "breathLoop")
          }
        }else{
          worldTimer.removeAction(forKey: timerID)
          self.members = self.members.filter { $0 != timerID }
        }
      }
    }
  }
  
  
  func startTimerActions(){
    self.movementTimer()
    self.targetTimer()
    self.pauseTimer()
    self.dataTimer()
    self.saveTimer()
  }
}
