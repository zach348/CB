

import Foundation
import SpriteKit

struct MotionControl {
  
  public static func correctMovement(){
    self.correctSpeedSD()
    self.correctMeanSpeed()
    self.correctSpeedRange()
    self.wallPush()
  }
  
  
  public static func circleMovement(duration:TimeInterval){
    if let timer = currentGame.timer, let gameScene = currentGame.gameScene {
      timer.members.forEach({ loop in
        if loop != "" {timer.stopTimer(timerID: loop)}
      })
      let concentrics = self.generateConcentrics()
      for index in 0..<Ball.members.count {
        let ball = Ball.members[index], incrementalDuration = duration / 4
        var inActions = [SKAction](), outActions = [SKAction](), trajectory = [CGPoint](), legIndices = [Int]()
        for pointsIndex in stride(from: 0, through: concentrics.count - 1, by: 2){
          let point = concentrics[pointsIndex][index]
          trajectory.append(point)
        }
        legIndices.append((trajectory.count - 1) / 10 * 4)
        legIndices.append((trajectory.count - 1) / 10 * 7)
        legIndices.append((trajectory.count - 1) / 10 * 9)
        legIndices.append(trajectory.count - 1)
        
        for legIndex in legIndices {
          inActions.append(SKAction.move(to: trajectory[legIndex], duration: incrementalDuration))
          outActions.append(SKAction.move(to: trajectory.reversed()[legIndex], duration: incrementalDuration))
        }
        let moveOutSequence = SKAction.sequence(outActions)
        let moveInSequence = SKAction.sequence(inActions)
        let inWait = SKAction.wait(forDuration: 3)
        let outWait = SKAction.wait(forDuration: 1.5)
        let moveToCenter = SKAction.move(to: trajectory.first!, duration: 2)
        let wait = SKAction.wait(forDuration: 2)
        let centerSequence = SKAction.sequence([moveToCenter,wait])
        let sequence = SKAction.sequence([moveOutSequence,outWait,moveInSequence,inWait])
        ball.run(centerSequence, completion: { ball.run(SKAction.repeatForever(sequence)) })
        
        //create a speed bleed/transition function
        ball.physicsBody?.velocity.dx = 0
        ball.physicsBody?.velocity.dy = 0
        


      }
    }
  }
  
  
  
  private static func correctMeanSpeed(){
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
  
  private static func correctSpeedSD(){
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
  
  private static func correctSpeedRange(){
    for ball in Ball.members {
      if ball.currentSpeed() < Game.currentSettings.minSpeed {ball.modifySpeed(factor: 1.01)}
      else if ball.currentSpeed() > Game.currentSettings.maxSpeed {ball.modifySpeed(factor: 0.99)}
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
  
  
  
  ///////////RESP//////////////////////////////////
  
  private static func generateConcentrics() -> [[CGPoint]] {
    var concentricCircles = [[CGPoint]]()
    if let gameScene = currentGame.gameScene {
      for radius in 70...Int(gameScene.size.height/2) {
        concentricCircles.append(MotionControl.circlePoints(numPoints: Ball.members.count, anchorX: 0, anchorY: 0, radius: CGFloat(radius)))
      }
    }
    return concentricCircles
  }
  
  //gist
  private static func circlePoints(numPoints:Int, anchorX: CGFloat, anchorY: CGFloat, radius: CGFloat, precision:Int = 3) -> [CGPoint] {
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
}
