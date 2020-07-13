

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var gameViewController:GameViewController?
  static var currentUser = Auth.auth().currentUser
  static var initialRequest:Bool = true
  static var db:Firestore = Firestore.firestore()
  static var metaGameRef:DocumentReference = db.document("meta/gameMeta")
  static var gameCount = 0
  static var records = [[String:Any]]()
  static var eventMarkers:[String:Any] = [
    "didShift": ["flag": false, "delay": -1],
    "didAttempt": ["flag": false, "success": -1, "stagePoints": -1]
  ]
  static var ballInfo:[[String:Any]] = [[String:Any]]()
  static var user:[String:Any] = [
    "diffMod": 0.7,
    "gamesPlayedCount": 0,
    "completedGamesCount": 0,
    "completedBackgroundSurvey": false,
    "completedGeneralSurvey": false,
    "lastUpdated": FieldValue.serverTimestamp()
    ] {
    didSet {
      if let userId = self.currentUser?.email {
        self.db.collection("users").document(userId).updateData(user)
      }
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
        "diffMod": self.user["diffMod"],
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
    self.metaGameRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      guard let document = document else { print("Games metadoc not found: \(error?.localizedDescription ?? "No error returned")"); return }
      guard let gameCount:Any = document.get("gameCount") else { print("Games count not found"); return }
      
      print("gameCount, dummy request:", gameCount)
      
    })
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
        Survey.updateSurveyStatus()
        Survey.SMCustomVars["user"] = userId
      } else {
        collectionRef.document(userId).setData([
          "diffMod": 0.70,
          "gamesPlayedCount": 0,
          "completedGamesCount":0,
          "completedGeneralSurvey": false,
          "completedBackgroundSurvey": false,
          "lastUpdated": FieldValue.serverTimestamp()
        ])
        print("no user found, writing user doc and incrementing...")
        metaUsersRef.updateData(["userCount": FieldValue.increment(Int64(1)), "lastUpdated": FieldValue.serverTimestamp()])
        self.getUser(userId: userId)
      }
    }
  }
  

  
  static func incrementUserGameCount(userId:String){
    self.db.collection("users").document(userId).updateData(["gamesPlayedCount": FieldValue.increment(Int64(1))])
  }
  
  static func incrementGlobalGameCount(){
    self.metaGameRef.updateData(["gameCount": FieldValue.increment(Int64(1)), "lastUpdated": FieldValue.serverTimestamp()])
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
  
  static func getGameCount(){
    self.metaGameRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      if let error = error {
        print("getGameCount error: ", error, error.localizedDescription)
      }else if let document = document, document.exists {
        guard let gameCount = document.get("gameCount") as? Int else { print("game count not found on returned document"); return }
        self.gameCount = gameCount
      }
    })
  }
  
  static func initiateGame(){
    guard let currentUser = self.currentUser, let userId = currentUser.email, let gamesPlayedCount = self.user["gamesPlayedCount"] as? Int else { print("error retrieving current user from DataStore"); return}
    self.incrementGlobalGameCount()
    self.user["gamesPlayedCount"] = gamesPlayedCount + 1
    self.metaGameRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      if let error = error {
        print("error getting game meta doc________initiateGame()", error, error.localizedDescription)
      }else if let document = document, document.exists {
        guard let gameCount = document.get("gameCount") as? Int else { print("Errpr: gameCount not found on meta doc_______initiateGame()"); return }
        self.gameCount = gameCount
        Survey.SMCustomVars["gameId"] = self.gameCount
        self.db.collection("games").document("\(gameCount)").setData([
          "lastUpdated": FieldValue.serverTimestamp(),
          "userEmail": userId
        ]) { error in
         if let error = error {
           print("error writing game document:", error, error.localizedDescription)
         } else {
           print("game document written")
         }
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
