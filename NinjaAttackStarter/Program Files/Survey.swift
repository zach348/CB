

import Foundation
import SpriteKit

struct Survey {
  static var willDeployPrePostSurvey:Bool = false
  static var willDeployGeneralSurvey:Bool = false
  static var feedbackState:String = ""
  static var surveys:[String:Any] = ["activePre": "", "activePost": "", "general": ""]

  static func getSurveys(){
    let collectionRef = DataStore.db.collection("params")
    let surveyDocRef = collectionRef.document("surveys")
    surveyDocRef.getDocument { (document, error) in
      if let error = error { print("error getting survey document:", error, error.localizedDescription)}
      if let document = document, document.exists {
        print("found survey document")
        guard let surveyData = document.data() else { print("error extracting survey data"); return }
        self.surveys = surveyData
        print(self.surveys)

      } else {
        print("no survey document found")
      }
    }
  }

  static func updateSurveyStatus(){
    if let userGames = DataStore.user["gamesPlayedCount"] as? Int, let completedGames = DataStore.user["completedGamesCount"] as? Int, let completedGeneralSurvey = DataStore.user["completedGeneralSurvey"] as? Bool {
      self.willDeployPrePostSurvey = userGames >= 3 && completedGames >= 1 ? true : false
      Survey.willDeployGeneralSurvey = completedGeneralSurvey ? false : true
    }
  }
  
  static func presentSurvey(surveyHash:String, gvc:GameViewController){
    print(self.willDeployGeneralSurvey)
    gvc.prepareSurveyViewController(surveyHash: surveyHash)
    if let fbController = gvc.feedBackController  { fbController.present(from: gvc, animated: true, completion: nil ) }
  }
}
