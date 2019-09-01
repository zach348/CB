

import Foundation
import SpriteKit

struct DataStore {
  static var records = [DataStore]()
  
  static func addRecord(){
    if let timer = currentGame.timer, let scene = currentGame.gameScene {
      timer.stopTimer(timerID: "dataTimer")
      self.records.append(self.init(bpm: currentGame.bpm))
      let dataTimer = SKAction.run {
        timer.dataTimer()
      }
      scene.run(dataTimer)
    }
  }
  
  let elapsedTime:Double
  let isResponding:Bool
  let bpm:Int
  let meanSpeed:CGFloat
  let speedSD:CGFloat
  //from Settings
  let phase:Int
  let requiredStreak:Int
  let pauseDelay:Double
  let pauseError:Double
  let pauseDuration:Double
  let frequency:Double
  let toneFile:String
  let targetMeanSpeed:CGFloat
  let targetSpeedSD:CGFloat
  let shiftDelay:Double
  let shiftError:Double
  let numTargets:Int
  let ballCount:Int
  let targetTexture:String
  let distractorTexture:String
  
  init(bpm:Int){
    self.elapsedTime = currentGame.timer!.elapsedTime
    self.isResponding = currentGame.isPaused
    self.bpm = bpm
    self.meanSpeed = Ball.mean()
    self.speedSD = Ball.standardDev()
    self.phase = Game.currentTrackSettings.phase
    self.requiredStreak = Game.currentTrackSettings.requiredStreak
    self.pauseDelay = Game.currentTrackSettings.pauseDelay
    self.pauseError = Game.currentTrackSettings.pauseError
    self.pauseDuration = Game.currentTrackSettings.pauseDuration
    self.frequency = Game.currentTrackSettings.frequency
    self.toneFile = Game.currentTrackSettings.toneFile
    self.targetMeanSpeed = Game.currentTrackSettings.targetMeanSpeed
    self.targetSpeedSD = Game.currentTrackSettings.targetSpeedSD
    self.shiftDelay = Game.currentTrackSettings.shiftDelay
    self.shiftError = Game.currentTrackSettings.shiftError
    self.numTargets = Game.currentTrackSettings.numTargets
    self.ballCount = Ball.members.count
    self.targetTexture = Game.currentTrackSettings.targetTexture.description
    self.distractorTexture = Game.currentTrackSettings.distractorTexture.description
  }
}
