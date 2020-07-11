

import UIKit
import SpriteKit
import Firebase

class GameViewController: UIViewController, TransitionDelegate, SMFeedbackDelegate {
  
  var loginScene:LoginScene?
  var startScene:StartGameScene?
  var gameScene:GameScene?
  var surveyController:SMFeedbackViewController?

  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataStore.gameViewController = self
    UIApplication.shared.isIdleTimerDisabled = true
    loginScene = LoginScene(size: view.bounds.size)
    loginScene?.gameViewController = self
    loginScene?.scaleMode = .fill
    loginScene?.delegate = self as TransitionDelegate
    loginScene?.anchorPoint = CGPoint.zero
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsPhysics = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    skView.presentScene(loginScene)
    
   Auth.auth().addStateDidChangeListener { (auth, user) in
      // ...
    Survey.willDeployPrePostSurvey = false
    Survey.willDeployGeneralSurvey = false
      if user != nil && !user!.isEmailVerified{
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
      } else if user != nil && user!.isEmailVerified {
        print("logged in")
        guard let userId = user?.email else {print("error retrieving userId"); return}
        DataStore.dummyRequest()
        print("getting user... ")
        DataStore.getUser(userId: userId)
        
        //Prepare start screen
        self.startScene = StartGameScene(size: (self.view.bounds.size))
        self.startScene?.gameViewController = self
        
        
        //present start scene and cleanup loginScene
        skView.presentScene(self.startScene)
        self.loginScene = nil
        
        //testing
      }else{
        print("logged out")
        self.loginScene = LoginScene(size: self.view.bounds.size)
        self.loginScene?.delegate = self as TransitionDelegate
        self.loginScene?.anchorPoint = CGPoint.zero
        self.loginScene?.scaleMode = .fill
        self.loginScene?.gameViewController = self
        skView.presentScene(self.loginScene)
      }
    }
    
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
      UIApplication.shared.isIdleTimerDisabled = false
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
      if motion == .motionShake {
          if let skView = view as? SKView, let scene = skView.scene as? GameScene {
              scene.shake()
          }
      }
  }
  
  func showAlert(title:String,message:String,params:[String:Bool] = [String:Bool]()) {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Ok", style: .default) { action in
       
        
        
        
        
        //handle quit param and game cleanup
        if let quitGame = params["quitGame"], let timer = currentGame.timer {
          if quitGame {
            guard let userId = Auth.auth().currentUser?.email else { print("error getting userId to quit game"); return}
            let skView = self.view as! SKView
            
            Survey.feedbackState = "pre"
            if let preHash = Survey.surveys["activePre"], let preHashString = preHash as? String {
              self.prepareSurveyViewController(surveyHash: preHashString)
            }
            
            self.startScene = StartGameScene(size: (self.view.bounds.size))
            self.startScene?.gameViewController = self
            if Survey.willDeployGeneralSurvey {
              if let generalHash = Survey.surveys["general"], let generalHashString = generalHash as? String {
                self.prepareSurveyViewController(surveyHash: generalHashString)
                print("general hash: ", generalHashString)
                Survey.feedbackState = "general"
//                if let fbController = self.feedBackController { fbController.present(from: self, animated: true, completion: nil) }
                Survey.presentSurvey(surveyHash: generalHashString, gvc: self)
              }
            }
            skView.presentScene(self.startScene)
            self.gameScene?.removeAllActions()
            self.gameScene?.removeAllChildren()
            self.gameScene = nil
//            DataStore.saveGame()
            timer.stopTimers(timerArray: ["saveTimer"])
            currentGame = Game()
           
          }
        } else {
          print("handle Ok action...no quitGame param")
        }
      })
      alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
      self.present(alertController, animated: true)
  }
  func handleLoginBtn(username:String,password:String) {
    Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
      guard let strongSelf = self else { return }
      if let error = error {
        strongSelf.showAlert(title: "Login Error", message: error.localizedDescription)
      }
      if let authResult = authResult {
        if !authResult.user.isEmailVerified {
          strongSelf.showAlert(title: "Login Error", message: "Please verify your email before logging in")
        }
      }
    }
  }
  func handleCreateBtn(username:String,password:String){
    Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
      if let error = error {
        self.showAlert(title: "Account Creation Error", message: error.localizedDescription)
      }else if let authResult = authResult, let email = authResult.user.email {
        let skView = self.view as! SKView
        self.startScene = StartGameScene(size: self.view.bounds.size)
        self.startScene?.gameViewController = self
        skView.presentScene(self.startScene)
        self.loginScene = nil
        self.showAlert(title: "Account Creation Successful", message: "An email verification link has been sent to \(email)")
        authResult.user.sendEmailVerification(completion: { error in
          if let error = error {
            print("email verification send error: \(error.localizedDescription)")
          }
        })
      }
    }
  }
  
  //survey monkey
  

  
  func prepareSurveyViewController(surveyHash:String){
    self.surveyController = SMFeedbackViewController.init(survey: surveyHash)
    self.surveyController!.delegate = self
  }
  
  func respondentDidEndSurvey(_ respondent: SMRespondent!, error: Error!) {
    print("respondent did end survey; feedback state: ", Survey.feedbackState);
    if let error = error {
      print("Survey error:",error,error.localizedDescription)
      //API always returning errors until account is upgraded
    } else if let respondent = respondent {
      print("received respondent/valid response ******************", respondent.description)
      if Survey.feedbackState == "general" {
        DataStore.user["completedGeneralSurvey"] = true
        Survey.feedbackState = ""
      }else if Survey.feedbackState == "background" {
        DataStore.user["completedBackgroundSurvey"] = true
        Survey.feedbackState = ""
      }else if Survey.feedbackState == "pre", let startScene = self.startScene {
        print("T1 survey completed")
        Survey.feedbackState = ""
        startScene.presentGameScene()
      }else if Survey.feedbackState == "post"{
        print("T2 survey completed")
        Survey.feedbackState = ""
        guard let timer = currentGame.timer, let worldTimer = currentGame.worldTimer else { return }
        Sensory.createHapticEngine()
        Sensory.prepareHaptics()
        Sensory.applyFrequency() 
        Game.transitionRespPhase(timer: timer, worldTimer: worldTimer)
      }
    }
    Survey.updateSurveyStatus()
  }
  
}
