

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var records = [[String:Any]]()
  static var eventMarkers = [String:Any]()
  
  static func addRecord(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      timer.stopTimer(timerID: "dataTimer")
      let record:[String:Any] = [
        "elapsedTime": currentGame.timer!.elapsedTime,
        "isResponding": currentGame.isPaused,
        "bpm": currentGame.bpm,
        "meanSpeed": Ball.mean(),
        "speedSD": Ball.standardDev(),
        "phase": Game.currentTrackSettings.phase,
        "requiredStreak": Game.currentTrackSettings.requiredStreak,
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
          "didShift": self.eventMarkers["didShift"]
        ]
      ]
      self.records.append(record)
      self.eventMarkers = [
        "didShift": ["status": false, "delay": -1]
      ]
      
      let dataTimer = SKAction.run {
        timer.dataTimer()
      }
      scene.run(dataTimer)
    }
  }
  
  static func saveTimePoint(tpRecord:[String:Any],tpCount:Int){
    let db = Firestore.firestore()
    let metaGamesRef = db.document("meta/games")

    metaGamesRef.getDocument { (document, error) in
      if let document = document {
        if let gamesCount:Any = document.get("count") {
          let tpSavePath:String = "\(gamesCount)/\(tpCount)"
          db.document(tpSavePath).setData(tpRecord) { (error) in
            if let error = error {
              print("error: \(error.localizedDescription)")
            } else {
              print("Data has been saved")
            }
          }
        }
      }else{
        print("Games metadoc not found")
      }
    }
  }
  
  static func saveGame(){
    let db = Firestore.firestore()
    let metaGamesRef = db.document("meta/games")
    var counter:Int = 1
    for tpRecord in self.records {
      self.saveTimePoint(tpRecord: tpRecord, tpCount: counter)
      counter += 1
    }
    metaGamesRef.updateData(["count": FieldValue.increment(Int64(1))])
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
}
