

import Foundation
import SpriteKit
import Firebase

struct DataStore {
  static var records = [String: Any]()
  static var eventMarkers = [String:Any]()
  
  static func addRecord(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      timer.stopTimer(timerID: "dataTimer")
      let count = self.records.count
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
      self.records["\(count+1)"] = record
      self.eventMarkers = [
        "didShift": ["status": false, "delay": -1]
      ]
      
      let dataTimer = SKAction.run {
        timer.dataTimer()
      }
      scene.run(dataTimer)
    }
  }
  
  static func saveGame(){
    let docRef = Firestore.firestore().document("sample_games/test_data")
    let dataToSave:[String:Any] = self.records
    
    docRef.setData(dataToSave) { (error) in
      if let error = error {
        print("error: \(error.localizedDescription)")
      } else {
        print("Data has been saved")
      }
    }
  }
  
  static func printData(){
    let docRef = Firestore.firestore().document("sample_games/test_data")
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
