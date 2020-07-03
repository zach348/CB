

import Foundation
import SpriteKit
import UIKit
import Firebase

class StartGameScene: SKScene {
  weak var gameViewController:GameViewController?
  var startButton: Button! = nil
  var saveGameButton: Button! = nil
  var difficultyButton: Button! = nil
  var loginStatusLabel:SKLabelNode = SKLabelNode()
  var logOutLabel:SKLabelNode = SKLabelNode()
  
  
  var background = SKSpriteNode(imageNamed: "sphere-gray")
  
  override func didMove(to view: SKView) {
    background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    background.size = CGSize(width: self.frame.width/2, height: self.frame.height/2)
    addChild(background)
    
    backgroundColor = SKColor.white
    let buttonTexture:SKTexture! = SKTexture(imageNamed: "buttonUnselected.png")
    let buttonTextureSelected:SKTexture! = SKTexture(imageNamed: "buttonSelected.png")
    
    self.startButton = Button(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
    self.startButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(StartGameScene.handleStartButton))
    self.startButton.setButtonLabel(title: "Start Game", font: "Arial", fontSize: 20)
    if self.view!.frame.width < 670 {
      self.startButton.size = CGSize(width: 150, height: 30)
//      setting with diff button
//      self.startButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY  + 25)
      self.startButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY)

    }else{
      self.startButton.size = CGSize(width: 250, height: 50)
//      setting with diff button
//      self.startButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY + 50)
      self.startButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY)
    }
    self.startButton.zPosition = 1
    self.startButton.name = "button"
    self.addChild(self.startButton)
    
    self.difficultyButton = Button(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture, toggleButton: false)
    self.difficultyButton.setButtonAction(target: self, triggerEvent: .TouchDown, action: #selector(StartGameScene.changeDifficulty))
    self.difficultyButton.setButtonLabel(title: "\(currentGame.diffSetting)" as NSString, font: "Arial", fontSize: 20)
    if self.view!.frame.width < 670 {
      self.difficultyButton.size = CGSize(width: 150, height: 30)
      self.difficultyButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY - 30)
    }else{
      self.difficultyButton.size = CGSize(width: 250, height: 50)
      self.difficultyButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY - 50)
    }
    self.difficultyButton.zPosition = 1
    self.difficultyButton.name = "diffBtn"
    
//    REMOVED DIFF BUTTON FOR TESTING
//    self.addChild(self.difficultyButton)
    
    if let user = Auth.auth().currentUser, let email = user.email{
      
      self.loginStatusLabel.text = "You are currently logged in as \(email)"
      self.loginStatusLabel.fontSize = 15
      self.loginStatusLabel.fontColor = SKColor.black
      self.loginStatusLabel.fontName = "Arial"
      self.loginStatusLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/11)
      self.addChild(self.loginStatusLabel)
      
      self.logOutLabel.text = "Log Out"
      self.logOutLabel.name = "logOutLabel"
      self.logOutLabel.fontSize = 15
      self.logOutLabel.fontColor = SKColor.blue
      self.logOutLabel.fontName = "Arial"
      self.logOutLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/11 - 20)
      self.addChild(self.logOutLabel)
    }
    
    
    
    
    
    
    self.saveGameButton = Button(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture, toggleButton: true)
    self.saveGameButton.setButtonAction(target: self, triggerEvent: .TouchDown, action: #selector(StartGameScene.toggleSaveGame))
    self.saveGameButton.setButtonLabel(title: "Save Game", font: "Arial", fontSize: 20)
    self.saveGameButton.size = CGSize(width: 250, height: 50)
    self.saveGameButton.position = CGPoint(x: self.frame.width/2, y: self.frame.midY - 40)
    self.saveGameButton.zPosition = 1
    self.saveGameButton.name = "saveButton"
    
    //commented out for testflight
//    self.addChild(self.saveGameButton)
  
    
    //Testing
  }
  

  @objc func presentGameScene(){
    run(SKAction.sequence([
      SKAction.wait(forDuration: 0.25),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self, let gameViewController = self.gameViewController else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 1.5)
        gameViewController.gameScene = GameScene(size: self.size)
        gameViewController.gameScene?.gameViewController = gameViewController
        self.view?.presentScene(gameViewController.gameScene!, transition:reveal)
        self.gameViewController?.startScene = nil
      }
      ]))
  }
  
  @objc func handleStartButton(){
    if Survey.willDeployPrePostSurvey {
      if let gvc =  self.gameViewController, let feedbackController = gvc.feedBackController, let preHash = Survey.surveys["activePre"], let preHashString = preHash as? String {
        print("preparing survey")
        Survey.feedbackState = "pre"
        gvc.prepareSurveyViewController(surveyHash: preHashString)
        print("presenting survey...")
        feedbackController.present(from: gvc, animated: true, completion: nil)
      }else{
        print("error assigning gvc or feedback controller")
      }
    } else {
      self.presentGameScene()
    }
  }
  
  @objc func changeDifficulty(){
    switch currentGame.diffSetting {
      case .Normal: currentGame.diffSetting = .Hard
      case .Hard: currentGame.diffSetting = .Easy
      case .Easy: currentGame.diffSetting = .Normal
    }
    self.difficultyButton.setButtonLabel(title: "\(currentGame.diffSetting)" as NSString, font: "Arial", fontSize: 20)
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
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let touch = touches.first
         let positionInScene = touch!.location(in: self)
         let touchedNode = self.atPoint(positionInScene)

         if let name = touchedNode.name {
             switch name {
                 case "logOutLabel":
                  let firebaseAuth = Auth.auth()
                  do {
                    try firebaseAuth.signOut()
                  } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                  }
                 default:break
             }
         }
     }
}
