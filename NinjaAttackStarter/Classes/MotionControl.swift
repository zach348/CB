

import Foundation
import SpriteKit

class MotionControl {
  static var speedMeanTarget:CGFloat = 350
  static var speedSdTarget:CGFloat = 0
  
  class func correctMeanSpeed(){
    let currentMeanSpeed = Ball.mean()
    for ball in Ball.members {
      if currentMeanSpeed < MotionControl.speedMeanTarget {
        ball.accelerate()
      }
      else if currentMeanSpeed > MotionControl.speedMeanTarget {
        ball.decelerate()
      }
    }
  }
  
  class func correctSpeedSD(){
    let currentSD = Ball.standardDev()
    for ball in Ball.members {
      if currentSD < MotionControl.speedSdTarget {
        if ball.currentSpeed() > MotionControl.speedMeanTarget {
          ball.accelerate()
        }else if ball.currentSpeed() < MotionControl.speedMeanTarget{
          ball.decelerate()
        }
      }else if currentSD > MotionControl.speedSdTarget {
        if ball.currentSpeed() > MotionControl.speedMeanTarget {
          ball.decelerate()
        }else if ball.currentSpeed() < MotionControl.speedMeanTarget {
          ball.accelerate()
        }
      }
    }
  }
}
