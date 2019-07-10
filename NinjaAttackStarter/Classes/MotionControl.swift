

import Foundation
import SpriteKit

struct MotionControl {
  
  public static func correctMovement(){
    self.correctSpeedSD()
    self.correctMeanSpeed()
    self.correctSpeedRange()
    self.wallPush()
  }
  
  ///////////RESP//////////////////////////////////
  
  public static func generateConcentrics() -> [[CGPoint]] {
    var concentricCircles = [[CGPoint]]()
    if let gameScene = currentGame.gameScene {
      for radius in 70...Int(gameScene.size.height/2) {
        concentricCircles.append(MotionControl.circlePoints(numPoints: Ball.members.count, anchorX: 0, anchorY: 0, radius: CGFloat(radius)))
      }
    }
    return concentricCircles
  }
  
  //gist
  public static func circlePoints(numPoints:Int, anchorX: CGFloat, anchorY: CGFloat, radius: CGFloat, precision:Int = 3) -> [CGPoint] {
    var points = [CGPoint]()
    let angle = CGFloat(Double.pi) / CGFloat(numPoints) * 2.0
    let p = CGFloat(pow(10.0, Double(precision)))
    
    for i in 0..<numPoints {
      let x = anchorX - radius * cos(angle * CGFloat(i))
      let roundedX = Double(round(p * x)) / Double(p)
      let y = anchorY - radius * sin(angle * CGFloat(i))
      let roundedY = Double(round(p * y)) / Double(p)
      points.append(CGPoint(x: roundedX, y: roundedY))
    }
    return points
  }
  
  ///TRACK FUNCTIONS
  public static func bleedSpeed(factor:CGFloat = 0.98){
    for ball in Ball.members {
      ball.modifySpeed(factor: factor)
    }
    if let timer = currentGame.timer { if Ball.mean() < 20 { timer.stopTimer(timerID: "movementTimer")}}
  }
  
  
  private static func correctMeanSpeed(){
    let currentMeanSpeed = Ball.mean()
    for ball in Ball.members {
      if currentMeanSpeed < Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentTrackSettings.maxSpeed {
        ball.modifySpeed(factor: 1.02)
      }
      else if currentMeanSpeed > Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentTrackSettings.minSpeed {
        ball.modifySpeed(factor: 0.98)
      }
    }
  }
  
  private static func correctSpeedSD(){
    let currentSD = Ball.standardDev()
    for ball in Ball.members {
      if currentSD < Game.currentTrackSettings.targetSpeedSD {
        if ball.currentSpeed() > Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentTrackSettings.maxSpeed {
          ball.modifySpeed(factor: 1.02)
        }else if ball.currentSpeed() < Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentTrackSettings.minSpeed{
          ball.modifySpeed(factor: 0.98)
        }
      }else if currentSD > Game.currentTrackSettings.targetSpeedSD{
        if ball.currentSpeed() > Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() > Game.currentTrackSettings.minSpeed {
          ball.modifySpeed(factor: 0.98)
        }else if ball.currentSpeed() < Game.currentTrackSettings.targetMeanSpeed && ball.currentSpeed() < Game.currentTrackSettings.maxSpeed{
          ball.modifySpeed(factor: 1.02)
        }
      }
    }
  }
  
  private static func correctSpeedRange(){
    for ball in Ball.members {
      if ball.currentSpeed() < Game.currentTrackSettings.minSpeed {ball.modifySpeed(factor: 1.01)}
      else if ball.currentSpeed() > Game.currentTrackSettings.maxSpeed {ball.modifySpeed(factor: 0.99)}
    }
  }
  
  private static func wallPush() {
      if let scene = currentGame.gameScene {
        for ball in Ball.members {
          ball.updatePositionHistory()
          if ball.ballStuckX() {
            if ball.position.x > scene.size.width {
              ball.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 0))
            }else{
              ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 0))
            }
          }
          if ball.ballStuckY() {
            if ball.position.y > scene.size.height {
              ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -3))
            }else{
              ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3))
            }
          }
        }
      }
  }
}
