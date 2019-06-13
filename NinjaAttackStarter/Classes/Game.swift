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
    Settings(phase: 1, targetMeanSpeed: 225, targetSpeedSD: 225, shiftDelay: 3, shiftError: 1, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", flashTexture: "sphere-red"),
    Settings(phase: 2, targetMeanSpeed: 175, targetSpeedSD: 150, shiftDelay: 5, shiftError: 2, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", flashTexture: "sphere-red"),
    Settings(phase: 3, targetMeanSpeed: 125, targetSpeedSD: 75, shiftDelay: 10, shiftError: 3, numTargets: 3, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", flashTexture: "sphere-red"),
    Settings(phase: 4, targetMeanSpeed: 75, targetSpeedSD: 20, shiftDelay: 15, shiftError: 4, numTargets: 4, targetTexture: "sphere-purple", distractorTexture: "sphere-neonGreen", flashTexture: "sphere-red"),
    Settings(phase: 5, targetMeanSpeed: 50, targetSpeedSD: 0, shiftDelay: 20, shiftError: 5, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-black", flashTexture: "sphere-red")
  ]
  static var currentSettings:Settings = settingsArr.first! {
    didSet{
      print("Settings changed"...)
    }
  }
  
  func transitionSettings(){
    //timer management
    self.timer?.stopTimer(timerID: "targetShiftTimer")
    self.timer?.members = self.timer!.members.filter { $0 != "targetShiftTimer" }
    self.timer?.startTargetTimer()
    print("shifting settings")
    //Art/Texture management
    print(Game.currentSettings.phase)
  }
  

  var gameScene:GameScene
  var timer:Timer?
  init(gameScene: GameScene){
    self.gameScene = gameScene
  }
  
  func setupGame(){
    //intitializations
    self.timer = Timer(gameScene: self.gameScene)
    
    //gamescene formatting
    gameScene.backgroundColor = .white
    gameScene.scaleMode = .aspectFit
    gameScene.physicsBody = SKPhysicsBody(edgeLoopFrom: gameScene.frame)
    gameScene.physicsWorld.gravity = .zero
    gameScene.physicsWorld.contactDelegate = gameScene
    
    //stimuli
    Ball.createBalls(num: 10, game: self)
    self.addMemberstoScene(collection: Ball.members)
  }
  
  func startGame(){
    self.timer?.startGameTimer()
    Ball.startMovement()
    self.timer?.startMovementTimer()
    self.timer?.startPhaseTimer()
    self.timer?.startTargetTimer()
    
  }
  
  func addMemberstoScene(collection: [SKSpriteNode]){
    for sprite in collection{
      gameScene.addChild(sprite)
    }
  }
}

