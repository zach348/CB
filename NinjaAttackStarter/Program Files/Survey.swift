

import Foundation
import SpriteKit

struct Survey {
  static var willDeployPrePostSurvey:Bool = false
  static var willDeployGeneralSurvey:Bool = false
  static var willDeployBackgroundSurvey:Bool = false
  static var feedbackState:String = ""
  static var surveys:[String:Any] = ["activePre": "", "activePost": "", "general": "", "background": ""]
  static var SMCustomVars = [String:Any]()

  static func getSurveys(){
    let collectionRef = DataStore.db.collection("params")
    let surveyDocRef = collectionRef.document("surveys")
    surveyDocRef.getDocument { (document, error) in
      if let error = error { print("error getting survey document:", error, error.localizedDescription)}
      if let document = document, document.exists {
        print("found survey document")
        guard let surveyData = document.data() else { print("error extracting survey data"); return }
        self.surveys = surveyData
        self.updateSurveyStatus()
        if self.willDeployBackgroundSurvey, let gvc = DataStore.gameViewController, let backgroundHash = Survey.surveys["background"], let backgroundHashString = backgroundHash as? String {
          if backgroundHashString != "" {
            Survey.feedbackState = "background"
            Survey.presentSurvey(surveyHash: backgroundHashString, gvc: gvc)
          }
        }else{
          print("error preparing background vars")
        }
      } else {
        print("no survey document found")
      }
    }
  }

  static func updateSurveyStatus(){
    if let userGames = DataStore.user["gamesPlayedCount"] as? Int, let completedGames = DataStore.user["completedGamesCount"] as? Int, let completedGeneralSurvey = DataStore.user["completedGeneralSurvey"] as? Bool, let completedBackgroundSurvey = DataStore.user["completedBackgroundSurvey"] as? Bool {
      self.willDeployPrePostSurvey = userGames >= 3 && completedGames >= 1 ? true : false
      self.willDeployGeneralSurvey = completedGeneralSurvey ? false : true
      self.willDeployBackgroundSurvey = completedBackgroundSurvey ? false : true
    }
  }
  
  static func presentSurvey(surveyHash:String, gvc:GameViewController){
    gvc.prepareSurveyViewController(surveyHash: surveyHash)
    if let surveyController = gvc.surveyController  { surveyController.present(from: gvc, animated: true, completion: nil ) }
  }
}
