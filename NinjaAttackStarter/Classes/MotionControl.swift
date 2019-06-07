

import Foundation
import SpriteKit

class MotionControl {
  static var speedMeanTarget:CGFloat = 200
  static var speedSdTarget:CGFloat = 0
  static var minSpeed:CGFloat = 300
  static var maxSpeed:CGFloat = 1200
  
  public class func correctMovement(){
    self.correctSpeedSD()
    self.correctMeanSpeed()
    self.correctSpeedRange()
  }
  
  private class func correctMeanSpeed(){
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
  
  private class func correctSpeedSD(){
    let currentSD = Ball.standardDev()
    for ball in Ball.members {
      if currentSD < MotionControl.speedSdTarget {
        if ball.currentSpeed() > MotionControl.speedMeanTarget && ball.currentSpeed() < MotionControl.maxSpeed {
          ball.modifySpeed(factor: 1.02)
        }else if ball.currentSpeed() < MotionControl.speedMeanTarget && ball.currentSpeed() > MotionControl.minSpeed{
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
  
  private class func correctSpeedRange(){
    for ball in Ball.members {
      if ball.currentSpeed() < MotionControl.minSpeed {ball.modifySpeed(factor: 1.01)}
      else if ball.currentSpeed() > MotionControl.maxSpeed {ball.modifySpeed(factor: 0.99)}
    }
  }
}
