

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var records = [[String:Any]]()
  static var eventMarkers:[String:Any] = [
    "didShift": ["flag": false, "delay": -1],
    "didAttempt": ["flag": false, "success": -1, "streakLength": -1]
  ]
  static var ballInfo:[String:Any] = ["speed": -1, "id": -1, "isTarget": -1, "positionHistory": -1]
  
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
        "streakLength": currentGame.streakLength,
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
          "didSAttempt": self.eventMarkers["didAttempt"]
        ],
        "ballInfo": self.ballInfo
      ]
      self.records.append(record)
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
  
  static func saveTimePoint(tpRecord:[String:Any],tpCount:Int, gameCount:Any){
    let db = Firestore.firestore()
    let timePointCollection = db.collection("games/\(gameCount)/timepoints")
    timePointCollection.document("\(tpCount)").setData(tpRecord)
  }
  
  static func saveGame(){
    let db = Firestore.firestore()
    let metaGamesRef = db.document("meta/games")
    var tpCounter:Int = 1
    
    metaGamesRef.updateData(["count": FieldValue.increment(Int64(1))])
    metaGamesRef.getDocument{ (document,error) in
      if let document = document {
        guard let gameCount:Any = document.get("count") else { print("Games count not found"); return }
        print("gameCount:", gameCount)
        for tpRecord in self.records {
//          self.saveTimePoint(tpRecord: tpRecord, tpCount: tpCounter, gameCount: gameCount)
//          tpCounter += 1
        }
      }else{
        print("Games metadoc not found")
      }
    }
  }
  
  static func deleteDocument(path:String){
    let docRef = Firestore.firestore().document(path)
    docRef.delete { (error) in
      if let error = error {
        print("error: \(error.localizedDescription)")
      }else{
        print("deleted")
      }
    }
  }
  
  static func printDocument(path:String){
    let docRef = Firestore.firestore().document(path)
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
      self.ballInfo = ["speed": ball.currentSpeed(), "id": name, "isTarget": ball.isTarget, "positionHistory": ball.positionHistory.map { ["x": $0.x, "y": $0.y] }]
    }
  }
}
