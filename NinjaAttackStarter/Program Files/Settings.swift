
import Foundation
import SpriteKit

struct Settings {
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
