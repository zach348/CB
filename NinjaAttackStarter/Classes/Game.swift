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
    Settings(phase: 1, phaseDuration: 20, targetMeanSpeed: 600, targetSpeedSD: 450, shiftDelay: 4, shiftError: 1, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", flashTexture: "sphere-red"),
    Settings(phase: 2, phaseDuration: 30, targetMeanSpeed: 500, targetSpeedSD: 325, shiftDelay: 7, shiftError: 2, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", flashTexture: "sphere-red"),
    Settings(phase: 3, phaseDuration: 40, targetMeanSpeed: 400, targetSpeedSD: 200, shiftDelay: 10, shiftError: 3, numTargets: 3, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", flashTexture: "sphere-red"),
    Settings(phase: 4, phaseDuration: 50, targetMeanSpeed: 300, targetSpeedSD: 100, shiftDelay: 15, shiftError: 4, numTargets: 4, targetTexture: "sphere-purple", distractorTexture: "sphere-neonGreen", flashTexture: "sphere-red"),
    Settings(phase: 5, phaseDuration: 60, targetMeanSpeed: 200, targetSpeedSD: 50, shiftDelay: 20, shiftError: 5, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-black", flashTexture: "sphere-red")
  ]
  static var currentSettings:Settings = settingsArr.first! {
    didSet {
      Ball.resetTextures()
      Ball.shiftTargets()
    }
  }
  class func advancePhase(){
    if let index = self.settingsArr.firstIndex(where: {setting in setting.phase == self.currentSettings.phase + 1 }), let timer = currentGame.timer {
      if index < self.settingsArr.count {
        self.currentSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
        print(index)
      }
    }
  }

  var gameScene:GameScene?
  var timer:Timer?
  var world:SKNode?
  var isPaused:Bool {
    didSet {
      if let gameTimer = self.timer {
        if self.isPaused {
          gameTimer.stopTimerActions()

        }else{
          print("unpause")
          gameTimer.startTimerActions()
          print(gameTimer.members)
        }
      }
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
      let wait = SKAction.wait(forDuration: 15)
      let unpauseWait = SKAction.wait(forDuration: 3)
      let pause = SKAction.run {currentGame.pauseGame()}
      let unpause = SKAction.run {currentGame.unpauseGame()}
      let sequence = SKAction.repeatForever(SKAction.sequence([wait,pause,unpauseWait,unpause]))
      self.gameScene?.run(sequence)
    }
  }
  
  func pauseGame(){
    if let world = self.world {
      world.isPaused = true
      self.isPaused = true
      Ball.freezeMovement()
      self.isPaused = true
      
      //testing
    }
  }
  
  func unpauseGame(){
    if let world = self.world {
      world.isPaused = false
      self.isPaused = false
      Ball.unfreezeMovement()
    }
  }
  
  func addMemberstoScene(collection: [SKSpriteNode]){
    if let actionNode = self.world {
      for sprite in collection{
        actionNode.addChild(sprite)
      }
    }
  }
  
  func transitionSettings(){
    //timer management
    if let gameTimer = currentGame.timer {
      gameTimer.stopTimer(timerID: "targetShiftTimer")
      gameTimer.members = self.timer!.members.filter { $0 != "targetShiftTimer" }
      gameTimer.startTargetTimer()
    }
    //diagnostics
    print(Game.currentSettings.phase)
  }
}

