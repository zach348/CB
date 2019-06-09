

import Foundation
import SpriteKit

class MotionControl {
  
  public class func correctMovement(){
    self.correctSpeedSD()
    self.correctMeanSpeed()
    self.correctSpeedRange()
  }
  
  private class func correctMeanSpeed(){
    let currentMeanSpeed = Ball.mean()
    for ball in Ball.members {
      if currentMeanSpeed < Game.currentSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentSettings.maxSpeed {
        ball.modifySpeed(factor: 1.02)
      }
      else if currentMeanSpeed > Game.currentSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentSettings.minSpeed {
        ball.modifySpeed(factor: 0.98)
      }
    }
  }
  
  private class func correctSpeedSD(){
    let currentSD = Ball.standardDev()
    for ball in Ball.members {
      if currentSD < Game.currentSettings.targetSpeedSD {
        if ball.currentSpeed() > Game.currentSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentSettings.maxSpeed {
          ball.modifySpeed(factor: 1.02)
        }else if ball.currentSpeed() < Game.currentSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentSettings.minSpeed{
          ball.modifySpeed(factor: 0.98)
        }
      }else if currentSD > Game.currentSettings.targetSpeedSD{
        if ball.currentSpeed() > Game.currentSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentSettings.minSpeed {
          ball.modifySpeed(factor: 0.98)
        }else if ball.currentSpeed() < Game.currentSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentSettings.maxSpeed{
          ball.modifySpeed(factor: 1.02)
        }
      }
    }
  }
  
  private class func correctSpeedRange(){
    for ball in Ball.members {
      if ball.currentSpeed() < Game.currentSettings.minSpeed {ball.modifySpeed(factor: 1.01)}
      else if ball.currentSpeed() > Game.currentSettings.maxSpeed {ball.modifySpeed(factor: 0.99)}
    }
  }
}
