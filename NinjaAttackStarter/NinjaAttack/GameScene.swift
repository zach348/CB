

import SpriteKit


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let ball   : UInt32 = 0b1       // 1
}

let currentGame:Game = Game()

class GameScene: SKScene {
  weak var gameViewController:GameViewController?
  
  override func didMove(to view: SKView) {
    currentGame.gameScene = self
    Game.settingsArr = Settings.settings[currentGame.diffSetting]!
    currentGame.setupGame()
    currentGame.startGame()
  }
    
  override func update(_ currentTime: TimeInterval) {
    if (Game.willSaveGame && !Game.didSaveGame){
      guard let timer = currentGame.timer else {return}
      if timer.elapsedTime - timer.lastPhaseShiftTime > 60 {
        DataStore.saveGame()
        Game.didSaveGame = true
        print("save command executed")
      }
    }
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
}
