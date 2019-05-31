

import Foundation
import SpriteKit

class MotionControl {
  static var speedMeanTarget:CGFloat = 500
  static var speedSdTarget:CGFloat = 100
  
  class func correctSpeed(){
    let currentMeanSpeed = Ball.mean()
    for ball in Ball.members {
      if currentMeanSpeed < MotionControl.speedMeanTarget {
        ball.physicsBody?.velocity.dx *= 1.01
        ball.physicsBody?.velocity.dy *= 1.01
        print("speeding")
      }else if currentMeanSpeed > MotionControl.speedMeanTarget {
        ball.physicsBody?.velocity.dx *= 0.99
        ball.physicsBody?.velocity.dy *= 0.99
        print("slowing")
      }
    }
  }
}
