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
  
  func recursiveTargetTimer() {
    if let gameWorld = currentGame.world {
      gameWorld.removeAction(forKey: "targetTimer")
      self.members = self.members.filter({ $0 != "targetTimer"})
      let wait = SKAction.wait(forDuration: Game.currentSettings.shiftDelay, withRange: Game.currentSettings.shiftError)
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
      if timerID == "gameTimer" || timerID == "frequencyLoop" {
        self.members = self.members.filter { $0 != timerID }
        scene.removeAction(forKey: timerID)
      }else{
        world.removeAction(forKey: timerID)
        self.members = self.members.filter { $0 != timerID }
      }
    }
  }
  
  
  
//  func stopTimerActions(){
//    for timer in self.members.filter({ $0 != "gameTimer" }) {
//      self.stopTimer(timerID: timer)
//    }
//  }
//
  func startTimerActions(){
    self.startMovementTimer()
    self.recursiveTargetTimer()
  }
}
