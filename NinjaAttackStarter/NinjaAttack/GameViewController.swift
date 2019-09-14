

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    
    
    
    let startScene = StartGameScene(size: view.bounds.size)
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsPhysics = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(startScene)
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
