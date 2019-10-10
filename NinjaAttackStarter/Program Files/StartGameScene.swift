

import Foundation
import SpriteKit

class StartGameScene: SKScene {
  var startButton: Button! = nil
  var saveGameButton: Button! = nil
  var background = SKSpriteNode(imageNamed: "sphere-gray")
  
  override func didMove(to view: SKView) {
    background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    background.size = self.frame.size
    addChild(background)
    
    backgroundColor = SKColor.white
    let buttonTexture:SKTexture! = SKTexture(imageNamed: "buttonUnselected.png")
    let buttonTextureSelected:SKTexture! = SKTexture(imageNamed: "buttonSelected.png")
    self.startButton = Button(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
    self.startButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(StartGameScene.startGame))
    self.startButton.setButtonLabel(title: "Start Game", font: "Arial", fontSize: 20)
    self.startButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    self.startButton.zPosition = 1
    self.startButton.name = "button"
    self.addChild(self.startButton)
    
    self.saveGameButton = Button(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture, toggleButton: true)
    self.saveGameButton.setButtonAction(target: self, triggerEvent: .TouchDown, action: #selector(StartGameScene.toggleSaveGame))
    self.saveGameButton.setButtonLabel(title: "Save Game", font: "Arial", fontSize: 20)
    self.saveGameButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/3)
    self.saveGameButton.zPosition = 1
    self.saveGameButton.name = "saveButton"
    
    //commented out for testflight
//    self.addChild(self.saveGameButton)

    //Haptics
    Sensory.createHapticEngine()
    
    //DataStore
    
    //Testing
  }
  

  @objc func startGame(){
    run(SKAction.sequence([
      SKAction.wait(forDuration: 1.0),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
  }
  
  @objc func toggleSaveGame(){
    if(self.saveGameButton.toggleOn){
      print("toggling off...")
      self.saveGameButton.toggleOn = false
      Game.willSaveGame = false
    }else{
      print("toggling on...")
      self.saveGameButton.toggleOn = true
      Game.willSaveGame = true
    }
  }
  
}
