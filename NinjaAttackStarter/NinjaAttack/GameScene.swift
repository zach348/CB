

import SpriteKit


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let ball   : UInt32 = 0b1       // 1
}

var currentGame:Game = Game()

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
      if timer.elapsedTime - timer.lastPhaseShiftTime > 60 && Game.respActive && !Game.didSaveGame {
        DataStore.saveGame()
        Game.didSaveGame = true
        print("save command executed")
      }
    }
  }
  
  func shake(){
    guard let gameviewcontroller = self.gameViewController else { print("no gvc");return}
    if currentGame.isRunning {
      gameviewcontroller.showAlert(title: "Quit Game", message: "Are you sure you want to quit?", params: ["quitGame": true])
    }
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
}
