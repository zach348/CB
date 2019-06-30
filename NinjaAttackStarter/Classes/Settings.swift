
import Foundation
import SpriteKit

struct Settings {
  let phase:Int
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
  let flashTexture:SKTexture
  let minSpeed:CGFloat = 300
  let maxSpeed:CGFloat = 1200
  
  init(phase:Int, phaseDuration:Double, pauseDelay:Double, pauseError:Double, pauseDuration:Double, frequency:Double, toneFile:String, targetMeanSpeed:CGFloat, targetSpeedSD:CGFloat, shiftDelay:Double, shiftError:Double,numTargets:Int, targetTexture:String, distractorTexture:String, flashTexture:String){
    self.phase = phase
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
    self.flashTexture = SKTexture(imageNamed: flashTexture)
  }
}
