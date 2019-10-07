import Foundation
import SpriteKit

struct RespSettings {
  let phase:Int
  let phaseDuration:Double
  let frequency:Double
  let inDuration:TimeInterval
  let inWait:TimeInterval
  let outDuration:TimeInterval
  let outWait:TimeInterval
  let moveToCenterDuration:TimeInterval
  let moveCenterWait:TimeInterval
  
  init(phase:Int, phaseDuration:Double, frequency:Double, inDuration:TimeInterval, inWait:TimeInterval, outDuration:TimeInterval, outWait:TimeInterval, moveToCenterDuration:TimeInterval, moveCenterWait:TimeInterval){
    self.phase = phase
    self.phaseDuration = phaseDuration
    self.frequency = frequency
    self.inDuration = inDuration
    self.inWait = inWait
    self.outDuration = outDuration
    self.outWait = outWait
    self.moveToCenterDuration = moveToCenterDuration
    self.moveCenterWait = moveCenterWait
  }
}
