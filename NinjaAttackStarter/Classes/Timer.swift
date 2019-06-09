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
 var members = [String]()
 var elapsedTime:CGFloat = 0
 var lastUpdateTime:CGFloat = 0
 var gameScene:GameScene
  
  init(gameScene:GameScene){
    self.gameScene = gameScene
  }
  
  func startGameTimer(){
    let wait = SKAction.wait(forDuration: 0.1)
    let count = SKAction.run {
      self.elapsedTime += 0.1
    }
    self.members.append("gameTimer")
    self.gameScene.run(SKAction.repeatForever(SKAction.sequence([wait,count])), withKey: "gameTimer")
  }
  
  func startMovementTimer(){
    let wait = SKAction.wait(forDuration: 0.1)
    let correctMovement = SKAction.run {
      MotionControl.correctMovement()
    }
    self.members.append("movementTimer")
    self.gameScene.run(SKAction.repeatForever(SKAction.sequence([wait,correctMovement])), withKey: "movementTimer")
  }
  
  func startPhaseTimer() {
    let wait = SKAction.wait(forDuration: 10)
    let phaseShift = SKAction.run {
      let currentPhase = Game.currentSettings.phase
      if currentPhase < Game.settingsArr.count {
        let newSettings = Game.settingsArr.filter { settings in
          settings.phase == currentPhase + 1
        }.first!
        Game.currentSettings = newSettings
        if let game = self.gameScene.game { game.transitionSettings() }
      }
    }
    self.members.append("phaseShiftTimer")
    self.gameScene.run(SKAction.repeatForever(SKAction.sequence([wait,phaseShift])), withKey: "phaseShiftTimer")
  }
  
  func startTargetTimer() {
    let wait = SKAction.wait(forDuration: Game.currentSettings.shiftDelay, withRange: Game.currentSettings.shiftError)
    let targetShift = SKAction.run {
      
      Ball.shiftTargets()
      print("shifting targets")
      print("Phase:", Game.currentSettings.phase)
    }
    self.members.append("targetShiftTimer")
    self.gameScene.run(SKAction.repeatForever(SKAction.sequence([wait,targetShift])), withKey: "targetShiftTimer")
  }
  
  func stopTimer(timerID:String) {
    self.gameScene.removeAction(forKey: timerID)
  }
}
