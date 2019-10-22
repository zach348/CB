
import Foundation
import SpriteKit

struct Settings {
  static let easySettings:[Settings] = [
    Settings(phase: 1, missesAllowed: 0, requiredStreak: 3, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2.5, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 550, targetSpeedSD: 300, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, missesAllowed: 0, requiredStreak: 3,  phaseDuration: 70, pauseDelay: 14, pauseError: 4, pauseDuration: 4, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 425, targetSpeedSD: 225, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, missesAllowed: 0, requiredStreak: 3, phaseDuration: 90, pauseDelay: 18, pauseError: 4, pauseDuration: 5, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 350, targetSpeedSD: 150, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.cyan,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 21, pauseError: 5, pauseDuration: 6, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 275, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 24, pauseError: 6, pauseDuration: 8, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 200, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, missesAllowed: 0, requiredStreak: 3, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, missesAllowed: 0, requiredStreak: 2, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 2.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]
  
  static let normalSettings:[Settings] = [
    Settings(phase: 1, missesAllowed: 0, requiredStreak: 3, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2.5, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 625, targetSpeedSD: 300, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, missesAllowed: 0, requiredStreak: 3,  phaseDuration: 70, pauseDelay: 14, pauseError: 4, pauseDuration: 4, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 525, targetSpeedSD: 225, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, missesAllowed: 0, requiredStreak: 3, phaseDuration: 90, pauseDelay: 18, pauseError: 4, pauseDuration: 5, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 425, targetSpeedSD: 150, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.cyan,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 21, pauseError: 5, pauseDuration: 6, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 325, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, missesAllowed: 0, requiredStreak: 3, phaseDuration: 120, pauseDelay: 24, pauseError: 6, pauseDuration: 8, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 225, targetSpeedSD: 0, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, missesAllowed: 0, requiredStreak: 3, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, missesAllowed: 0, requiredStreak: 2, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 2.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]
  
  static let hardSettings:[Settings] = [
    Settings(phase: 1, missesAllowed: 0, requiredStreak: 4, phaseDuration: 50, pauseDelay: 10, pauseError: 2, pauseDuration: 2.5, frequency: 18, toneFile: "tone200hz.wav", targetMeanSpeed: 625, targetSpeedSD: 350, shiftDelay: 4, shiftError: 2, numTargets: 1, targetTexture: "sphere-darkGray", distractorTexture: "sphere-darkGray", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 2, missesAllowed: 0, requiredStreak: 4,  phaseDuration: 70, pauseDelay: 14, pauseError: 4, pauseDuration: 4, frequency: 14, toneFile: "tone185hz.wav", targetMeanSpeed: 525, targetSpeedSD: 250, shiftDelay: 7, shiftError: 4, numTargets: 2, targetTexture: "sphere-blue1", distractorTexture: "sphere-blue2", borderColor: UIColor.cyan, flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 3, missesAllowed: 0, requiredStreak: 4, phaseDuration: 90, pauseDelay: 18, pauseError: 4, pauseDuration: 5, frequency: 10, toneFile: "tone170hz.wav", targetMeanSpeed: 425, targetSpeedSD: 150, shiftDelay: 10, shiftError: 6, numTargets: 3, targetTexture: "sphere-purple", distractorTexture: "sphere-magenta", borderColor: UIColor.cyan,flashTexture: "sphere-red", alpha: 1),
    Settings(phase: 4, missesAllowed: 0, requiredStreak: 4, phaseDuration: 120, pauseDelay: 21, pauseError: 5, pauseDuration: 6, frequency: 8, toneFile: "tone155hz.wav", targetMeanSpeed: 325, targetSpeedSD: 75, shiftDelay: 25, shiftError: 8, numTargets: 4, targetTexture: "sphere-darkTurquoise", distractorTexture: "sphere-green", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    Settings(phase: 5, missesAllowed: 0, requiredStreak: 4, phaseDuration: 120, pauseDelay: 24, pauseError: 6, pauseDuration: 8, frequency: 5, toneFile: "tone140hz.wav", targetMeanSpeed: 225, targetSpeedSD: 50, shiftDelay: 40, shiftError: 10, numTargets: 5, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //messing with duration for dev
    Settings(phase: 6, missesAllowed: 0, requiredStreak: 3, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 4.5, toneFile: "tone140hz.wav", targetMeanSpeed: 175, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange", distractorTexture: "sphere-gray", borderColor: UIColor.cyan, flashTexture: "sphere-white", alpha: 1),
    //Final settings is a dummy phase...
    Settings(phase: 7, missesAllowed: 0, requiredStreak: 2, phaseDuration: 900, pauseDelay: 40, pauseError: 10, pauseDuration: 8, frequency: 2.5, toneFile: "tone140hz.wav", targetMeanSpeed: 0, targetSpeedSD: 0, shiftDelay: 50, shiftError: 15, numTargets: 6, targetTexture: "sphere-orange-1", distractorTexture: "sphere-black", borderColor: UIColor.cyan, flashTexture: "sphere-orange", alpha: 1)
  ]

  
  let phase:Int
  let missesAllowed:Int
  let requiredStreak:Int
  let phaseDuration:Double
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
  let targetTexture:SKTexture
  let distractorTexture:SKTexture
  let borderColor:UIColor
  let flashTexture:SKTexture
  let alpha:CGFloat
  var minSpeed:CGFloat {
    get {
      return self.targetMeanSpeed - 5*self.targetSpeedSD
    }
  }
  var maxSpeed:CGFloat {
    get {
      return self.targetMeanSpeed + 5*self.targetSpeedSD
    }
  }
  
  init(phase:Int, missesAllowed:Int, requiredStreak:Int, phaseDuration:Double, pauseDelay:Double, pauseError:Double, pauseDuration:Double, frequency:Double, toneFile:String, targetMeanSpeed:CGFloat, targetSpeedSD:CGFloat, shiftDelay:Double, shiftError:Double,numTargets:Int, targetTexture:String, distractorTexture:String, borderColor:UIColor, flashTexture:String, alpha:CGFloat){
    self.phase = phase
    self.missesAllowed = missesAllowed
    self.requiredStreak = requiredStreak
    self.phaseDuration = phaseDuration
    self.pauseDelay = pauseDelay
    self.pauseError = pauseError
    self.pauseDuration = pauseDuration
    self.frequency = frequency
    self.toneFile = toneFile
    self.targetMeanSpeed = targetMeanSpeed
    self.targetSpeedSD = targetSpeedSD
    self.shiftDelay = shiftDelay
    self.shiftError = shiftError
    self.numTargets = numTargets
    self.targetTexture = SKTexture(imageNamed: targetTexture)
    self.distractorTexture = SKTexture(imageNamed: distractorTexture)
    self.borderColor = borderColor
    self.flashTexture = SKTexture(imageNamed: flashTexture)
    self.alpha = alpha
  }
}
