

import SpriteKit

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let ball   : UInt32 = 0b1       // 1
}

let currentGame:Game = Game()

class GameScene: SKScene {
 
  override func didMove(to view: SKView) {
    currentGame.gameScene = self
    currentGame.setupGame()
    currentGame.startGame()
  }
  
  override func update(_ currentTime: TimeInterval) {
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
}
