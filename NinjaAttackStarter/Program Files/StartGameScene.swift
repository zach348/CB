

import Foundation
import SpriteKit

class StartGameScene: SKScene {
  var button: SKNode! = nil
  
  override func didMove(to view: SKView) {
    // Create a simple red rectangle that's 100x44
    button = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 44))
    // Put it in the center of the scene
    button.position = CGPoint(x:self.frame.width/2, y:self.frame.height/2);
    
    self.addChild(button)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        print("tapped!")
      
    
  }
  
}
