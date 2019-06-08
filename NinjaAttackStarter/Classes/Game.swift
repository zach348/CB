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
  var gameScene:GameScene
  var timer:Timer?
  var settings:[Settings] = [Settings]()
  init(gameScene: GameScene){
    self.gameScene = gameScene
  }
  
  func setupGame(){
    self.timer = Timer(gameScene: self.gameScene)
    
    gameScene.backgroundColor = .white
    gameScene.scaleMode = .aspectFit
    gameScene.physicsBody = SKPhysicsBody(edgeLoopFrom: gameScene.frame)
    gameScene.physicsWorld.gravity = .zero
    gameScene.physicsWorld.contactDelegate = gameScene
    
    Ball.createBalls(num: 10, game: self)
    
    self.addMemberstoScene(collection: Ball.members)
  }
  
  func startGame(){
    self.timer?.startGameTimer()
    Ball.startMovement()
    self.timer?.startMovementTimer()
    
    //testing
    Ball.members.randomElement()?.blinkBall(imageId: "sphere-red")
  }
  
  func addMemberstoScene(collection: [SKSpriteNode]){
    for sprite in collection{
      gameScene.addChild(sprite)
    }
  }
  
  private func createSettings(){
    let phase1 = Settings(targetSpeed: 50, targetSD: 0, shiftDelay: 30, shiftSD: 5, numTargets: 5)
    let phase2 = Settings(targetSpeed: 75, targetSD: 20, shiftDelay: 25, shiftSD: 7, numTargets: 4)
    let phase3 = Settings(targetSpeed: 125, targetSD: 75, shiftDelay: 20, shiftSD: 4, numTargets: 4)
    let phase4 = Settings(targetSpeed: 175, targetSD: 150, shiftDelay: 10, shiftSD: 4, numTargets: 2)
    let phase5 = Settings(targetSpeed: 225, targetSD: 225, shiftDelay: 4, shiftSD: 1, numTargets: 1)
    self.settings += [phase1,phase2,phase3,phase4,phase5]
  }
}
