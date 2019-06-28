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

import Foundation
import SpriteKit

class Game {
  
  static var settingsArr:[Settings] = [
    Settings(phase: 1, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 1.5, frequency: 16, targetMeanSpeed: 650, targetSpeedSD: 375, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", flashTexture: "sphere-red"),
    Settings(phase: 2, phaseDuration: 70, pauseDelay: 15, pauseError: 4, pauseDuration: 2.5, frequency: 12, targetMeanSpeed: 500, targetSpeedSD: 275, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", flashTexture: "sphere-red"),
    Settings(phase: 3, phaseDuration: 80, pauseDelay: 22, pauseError: 6, pauseDuration: 5, frequency: 9, targetMeanSpeed: 375, targetSpeedSD: 175, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", flashTexture: "sphere-red"),
    Settings(phase: 4, phaseDuration: 100, pauseDelay: 30, pauseError: 6, pauseDuration: 7, frequency: 7, targetMeanSpeed: 275, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", flashTexture: "sphere-white"),
    Settings(phase: 5, phaseDuration: 120, pauseDelay: 35, pauseError: 8, pauseDuration: 8, frequency: 5, targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-black", flashTexture: "sphere-white")
  ]
  static var currentSettings:Settings = settingsArr[0] {
    didSet {
      if let timer = currentGame.timer {
        print(currentGame.timer!.members)
        timer.stopTimer(timerID: "frequencyLoopTimer")
        Sensory.applyFrequency()
      }
      Ball.resetTextures()
      if Ball.getTargets().count < Game.currentSettings.numTargets {
        if let newTarget = Ball.getDistractors().randomElement(){
          newTarget.isTarget = true
          newTarget.blinkBall()
        }
      }
    }
  }
  
  class func advancePhase(){
    if let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentSettings.phase + 1 }), let timer = currentGame.timer {
      if index < self.settingsArr.count {
        self.currentSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }
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
      if let world = self.world { scene.addChild(world) }
    //gamescene formatting
      scene.backgroundColor = .white
      scene.scaleMode = .aspectFit
      scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
      scene.physicsWorld.gravity = .zero
      scene.physicsWorld.contactDelegate = gameScene
      
      //stimuli
      Ball.createBalls(num: 10, game: self)
      self.addMemberstoScene(collection: Ball.members)
    }
  }
  
  func startGame(){
    if let masterTimer = currentGame.timer {
      masterTimer.startGameTimer()
      Ball.startMovement()
      self.timer?.startTimerActions()
      //testing
      Sensory.applyFrequency()
    }
  }
  
  func pauseGame(){
    if Ball.blinkFlag {
      Ball.pendingPause = true
      print("pending pause")
      return
    }
    if let world = self.world {
      world.isPaused = true
      self.isPaused = true
      Ball.freezeMovement()
      Ball.maskTargets()
      //testing
      self.pauseCountdownTimer()
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
  
  func pauseCountdownTimer(){
    if let gameScene = currentGame.gameScene {
      var timerNode: Double = Game.currentSettings.pauseDuration
      let timerLabel = SKLabelNode(fontNamed: "STHeitJ-Medium")
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

}

