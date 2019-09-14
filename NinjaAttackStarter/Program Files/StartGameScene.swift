

import Foundation
import SpriteKit

class StartGameScene: SKScene {
  var startButton: FTButtonNode! = nil
  
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.white
    let buttonTexture:SKTexture! = SKTexture(imageNamed: "buttonUnselected.png")
    let buttonTextureSelected:SKTexture! = SKTexture(imageNamed: "buttonSelected.png")
    self.startButton = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
    self.startButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(StartGameScene.startGame))
    self.startButton.setButtonLabel(title: "Start Game", font: "Arial", fontSize: 20)
    self.startButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    self.startButton.zPosition = 1
    self.startButton.name = "button"
    self.addChild(self.startButton)
  }
  

  @objc func startGame(){
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
  }
  
}
