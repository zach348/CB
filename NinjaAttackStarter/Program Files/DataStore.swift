

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var gameViewController:GameViewController?
  static var currentUser = Auth.auth().currentUser
  static var initialRequest:Bool = true
  static var surveys:[String:Any] = ["pre": "null", "post": "null"]
  static var db:Firestore = Firestore.firestore()
  static var metaRef:DocumentReference = db.document("meta/gameMetaData")
  static var gameCount = 0
  static var records = [[String:Any]]()
  static var eventMarkers:[String:Any] = [
    "didShift": ["flag": false, "delay": -1],
    "didAttempt": ["flag": false, "success": -1, "stagePoints": -1]
  ]
  static var ballInfo:[[String:Any]] = [[String:Any]]()
  static var user:[String:Any] = [
    "diffMod": 0.7,
    "lastUpdated": FieldValue.serverTimestamp()
    ] {
    didSet {
      Settings.diffMod = user["diffMod"] as! CGFloat
    }
  }
  
  static var tpCount = 1
  static var recordCount = 0
  
  static func addRecord(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      self.recordCount += 1
      timer.stopTimers(timerArray: ["dataTimer"])
      self.updateBallStats()
      let record:[String:Any] = [
        "timeStamp": FieldValue.serverTimestamp(),
        "elapsedTime": currentGame.timer!.elapsedTime,
        "isResponding": currentGame.isPaused,
        "bpm": currentGame.bpm,
        "meanSpeed": Ball.mean(),
        "speedSD": Ball.standardDev(),
        "phase": Game.currentTrackSettings.phase,
        "diffMod": Settings.diffMod,
        "requiredStreak": Game.currentTrackSettings.requiredStreak,
        "stagePoints": currentGame.stagePoints,
        "pauseDelay": Game.currentTrackSettings.pauseDelay,
        "pauseError": Game.currentTrackSettings.pauseError,
        "pauseDuration": Game.currentTrackSettings.pauseDuration,
        "frequency": Game.respActive ? Game.currentRespSettings.frequency : Game.currentTrackSettings.frequency,
        "toneFile": Game.currentTrackSettings.toneFile,
        "targetMeanSpeedæ": Game.currentTrackSettings.targetMeanSpeed,
        "targetSpeedSD": Game.currentTrackSettings.targetSpeedSD,
        "shiftDelay": Game.currentTrackSettings.shiftDelay,
        "shiftError": Game.currentTrackSettings.shiftError,
        "numTargets": Game.currentTrackSettings.numTargets,
        "ballCount": Ball.members.count,
        "respActive": Game.respActive,
        "inhaleDuration": Game.currentRespSettings.inDuration,
        "inhaleHoldDuration": Game.currentRespSettings.inWait,
        "exhaleDuration": Game.currentRespSettings.outDuration,
        "exhaleHoldDuration": Game.currentRespSettings.outWait,
        "targetTexture": Game.currentTrackSettings.targetTexture.description,
        "distractorTexture": Game.currentTrackSettings.distractorTexture.description,
        "eventMarkers": [
          "didShift": self.eventMarkers["didShift"],
          "didAttempt": self.eventMarkers["didAttempt"]
        ],
        "ballInfo": self.ballInfo,
        "outcomeHistory": currentGame.outcomeHistory.map({ (outcome) -> String in
          switch outcome {
          case Outcome.success:
            return "success"
          case Outcome.failure:
            return "failure"
          case Outcome.pass:
            return "pass"
          case Outcome.transition:
            return "transition"
          }
        })
      ]
      self.records.append(record)
      self.ballInfo = [[String:Any]]()
      self.eventMarkers = [
        "didShift": ["flag": false, "delay": -1],
        "didAttempt": ["flag": false, "success": -1]
      ]
      
      let dataTimer = SKAction.run {
        timer.dataTimer()
      }
      scene.run(dataTimer)
    }
  }
  
  static func dummyRequest(){
    if !self.initialRequest { return } else { self.initialRequest = false }
    self.metaRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      guard let document = document else { print("Games metadoc not found: \(error?.localizedDescription ?? "No error returned")"); return }
      guard let gameCount:Any = document.get("count") else { print("Games count not found"); return }
      
      print("gameCount, dummy request:", gameCount)
      
    })
  }
  
  static func getSurveys(){
    let collectionRef = db.collection("params")
    let surveyDocRef = collectionRef.document("surveys")
    surveyDocRef.getDocument { (document, error) in
      if let error = error { print("error getting survey document:", error, error.localizedDescription)}
      if let document = document, document.exists {
        print("found survey document")
        guard let surveyData = document.data() else { print("error extracting survey data"); return }
        self.surveys = surveyData
        print(self.surveys)
        //set flag for survey feedback and load T1 Survey
        if let preHash = DataStore.surveys["activePre"], let preHashString = preHash as? String, let gvc = DataStore.gameViewController{
          print("preparing survey")
          gvc.feedbackState = "pre"
          gvc.prepareSurvey(surveyHash: preHashString)
        }

      } else {
        print("no survey document found")
      }
    }
  }
  
  static func getUser(userId:String){
    let collectionRef = db.collection("users")
    let userDocRef = collectionRef.document(userId)
    let metaUsersRef = db.collection("meta").document("userMeta")
    userDocRef.getDocument { (document, error) in
      if let error = error { print("error getting user document:", error, error.localizedDescription)}
      if let document = document, document.exists {
        print("found user document")
        guard let userData = document.data() else { print("error extracting user data"); return }
        self.user = userData
      } else {
        collectionRef.document(userId).setData([
          "diffMod": 0.70,
          "lastUpdated": FieldValue.serverTimestamp()
        ])
        print("no user found, incrementing...")
        metaUsersRef.updateData(["userCount": FieldValue.increment(Int64(1)), "lastUpdated": FieldValue.serverTimestamp()])
        self.getUser(userId: userId)
      }
    }
  }
  
  static func updateUser(userId:String){
    let userDocRef = db.collection("users").document(userId)
    let userData:[String:Any] = ["diffMod": Settings.diffMod, "lastUpdated": FieldValue.serverTimestamp()]
    userDocRef.setData(userData)
  }
  
  static func saveTimePoint(tpRecord:[String:Any], gameCount:Any, tpCount:Int){
    let timePointCollection = self.db.collection("games/\(gameCount)/timepoints")
    DispatchQueue.global(qos: .utility).async {
      timePointCollection.document("\(tpCount)").setData(tpRecord)
    }
  }
  
  static func saveRecords(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      timer.stopTimers(timerArray: ["saveTimer"])
      
      for tpRecord in self.records {
        self.saveTimePoint(tpRecord: tpRecord, gameCount: self.gameCount, tpCount: self.tpCount)
        self.records.removeFirst()
        self.tpCount += 1

      }
      
      let saveTimer = SKAction.run {
        timer.saveTimer()
      }
      scene.run(saveTimer)
    }
  }
  
  static func initiateGame(){
    self.metaRef.updateData(["count": FieldValue.increment(Int64(1))])
    self.metaRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      guard let document = document else { print("Games metadoc not found: \(error?.localizedDescription ?? "No error returned")"); return }
      guard let gameCount:Any = document.get("count") else { print("Games count not found"); return }
      guard let currentUser = self.currentUser else {print("error retrieving current user from DataStore"); return}
      self.gameCount = gameCount as! Int
      self.db.collection("games").document("\(gameCount)").setData([
        "lastUpdated": FieldValue.serverTimestamp(),
        "userEmail": currentUser.email as Any
      ]) { error in
        if let error = error {
          print(error.localizedDescription)
        } else {
          print("game document written")
        }
      }
    })
    Game.didSaveGame = true
  }
  
  static func deleteDocument(path:String){
    let docRef = self.db.document(path)
    docRef.delete { (error) in
      if let error = error {
        print("error: \(error.localizedDescription)")
      }else{
        print("deleted")
      }
    }
  }
  
  static func printDocument(path:String){
    let docRef = self.db.document(path)
    docRef.getDocument { (document,error) in
      if let document = document, document.exists {
        let data = document.data().map(String.init(describing:)) ?? "nil"
        print("Doc Data: \(data)")
      }else{
        print("Doc does not exist")
      }
    }
  }

  
  private
  
  static func updateBallStats(){
    for ball in Ball.members{
      guard let name = ball.name else { break }
      self.ballInfo.append(["speed": ball.currentSpeed(), "id": name, "isTarget": ball.isTarget, "positionHistory": ball.positionHistory.map { ["x": $0.x, "y": $0.y] }])
    }
  }
}
