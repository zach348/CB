

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var initialRequest:Bool = true
  static var db:Firestore = Firestore.firestore()
  static var metaRef:DocumentReference = db.document("meta/games")
  
  static var records = [[String:Any]]()
  static var eventMarkers:[String:Any] = [
    "didShift": ["flag": false, "delay": -1],
    "didAttempt": ["flag": false, "success": -1, "stagePoints": -1]
  ]
  static var ballInfo:[[String:Any]] = [[String:Any]]()
  
  static func addRecord(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      timer.stopTimer(timerID: "dataTimer")
      self.updateBallStats()
      let record:[String:Any] = [
        "elapsedTime": currentGame.timer!.elapsedTime,
        "isResponding": currentGame.isPaused,
        "bpm": currentGame.bpm,
        "meanSpeed": Ball.mean(),
        "speedSD": Ball.standardDev(),
        "phase": Game.currentTrackSettings.phase,
        "requiredStreak": Game.currentTrackSettings.requiredStreak,
        "stagePoints": currentGame.stagePoints,
        "pauseDelay": Game.currentTrackSettings.pauseDelay,
        "pauseError": Game.currentTrackSettings.pauseError,
        "pauseDuration": Game.currentTrackSettings.pauseDuration,
        "frequency": Game.currentTrackSettings.frequency,
        "toneFile": Game.currentTrackSettings.toneFile,
        "targetMeanSpeedæ": Game.currentTrackSettings.targetMeanSpeed,
        "targetSpeedSD": Game.currentTrackSettings.targetSpeedSD,
        "shiftDelay": Game.currentTrackSettings.shiftDelay,
        "shiftError": Game.currentTrackSettings.shiftError,
        "numTargets": Game.currentTrackSettings.numTargets,
        "ballCount": Ball.members.count,
        "targetTexture": Game.currentTrackSettings.targetTexture.description,
        "distractorTexture": Game.currentTrackSettings.distractorTexture.description,
        "eventMarkers": [
          "didShift": self.eventMarkers["didShift"],
          "didAttempt": self.eventMarkers["didAttempt"]
        ],
        "ballInfo": self.ballInfo
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
  
  static func saveTimePoint(tpRecord:[String:Any], gameCount:Any){
    let db = Firestore.firestore()
    let timePointCollection = db.collection("games/\(gameCount)/timepoints")
    timePointCollection.addDocument(data: tpRecord)
  }
  
  
  static func dummyRequest(){
    if !self.initialRequest { return } else { self.initialRequest = false }
    self.metaRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      guard let document = document else { print("Games metadoc not found: \(error?.localizedDescription ?? "No error returned")"); return }
      guard let gameCount:Any = document.get("count") else { print("Games count not found"); return }
      
      print("gameCount, dummy request:", gameCount)
      
    })
  }
  
  static func saveGame(){
    self.metaRef.updateData(["count": FieldValue.increment(Int64(1))])
    self.metaRef.getDocument(source: FirestoreSource.server, completion: { (document,error) in
      guard let document = document else { print("Games metadoc not found: \(error?.localizedDescription ?? "No error returned")"); return }
      guard let gameCount:Any = document.get("count") else { print("Games count not found"); return }
      
      print("records count: \(self.records.count)")
      print("gameCount:", gameCount)
      for tpRecord in self.records.shuffled() {
        self.saveTimePoint(tpRecord: tpRecord, gameCount: gameCount)
      }
    })
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
