

import Foundation
import SpriteKit

class MotionControl {
  static var speedMeanTarget:CGFloat = 350
  static var speedSdTarget:CGFloat = 100
  static var minSpeed:CGFloat = 300
  static var maxSpeed:CGFloat = 1200
  
  class func correctMeanSpeed(){
    let currentMeanSpeed = Ball.mean()
    for ball in Ball.members {
      if currentMeanSpeed < MotionControl.speedMeanTarget && ball.currentSpeed() < MotionControl.maxSpeed {
        ball.modifySpeed(factor: 1.02)
      }
      else if currentMeanSpeed > MotionControl.speedMeanTarget && ball.currentSpeed() > MotionControl.minSpeed {
        ball.modifySpeed(factor: 0.98)
      }
    }
  }
  
  class func correctSpeedSD(){
    let currentSD = Ball.standardDev()
    for ball in Ball.members {
      if currentSD < MotionControl.speedSdTarget {
        if ball.currentSpeed() > MotionControl.speedMeanTarget {
          ball.modifySpeed(factor: 1.02)
        }else if ball.currentSpeed() < MotionControl.speedMeanTarget{
          ball.modifySpeed(factor: 0.98)
        }
      }else if currentSD > MotionControl.speedSdTarget {
        if ball.currentSpeed() > MotionControl.speedMeanTarget && ball.currentSpeed() > MotionControl.minSpeed {
          ball.modifySpeed(factor: 0.98)
        }else if ball.currentSpeed() < MotionControl.speedMeanTarget && ball.currentSpeed() < MotionControl.maxSpeed{
          ball.modifySpeed(factor: 1.02)
        }
      }
    }
  }
  
  class func correctSpeedRange(){
    for ball in Ball.members {
      if ball.currentSpeed() < MotionControl.minSpeed {ball.modifySpeed(factor: 1.02)}
      else if ball.currentSpeed() > MotionControl.maxSpeed {ball.modifySpeed(factor: 0.98)}
    }
  }
}
