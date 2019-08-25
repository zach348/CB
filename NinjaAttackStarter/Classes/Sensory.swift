
import Foundation
import SpriteKit
import AudioToolbox
import UIKit


struct Sensory {
  
  static var audioNodes: [String: SKAudioNode] = [
    "correct": SKAudioNode(fileNamed: "correct_sound"),
    "incorrect": SKAudioNode(fileNamed: "wrong_sound"),
    "streak": SKAudioNode(fileNamed: "streak_sound")
  ]
  
  static func foundTargetFeedback(foundTarget:Ball){
    switch Game.currentTrackSettings.phase {
    case 1,2:
      self.addParticles(sprite: foundTarget, emitterFile: "spark.sks")
      foundTarget.showBorder()
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      foundTarget.run(SKAction.run({
        self.audioNodes["correct"]?.run(SKAction.play())
      }))
    case 3:
      self.addParticles(sprite: foundTarget, emitterFile: "spark.sks")
    default:
      break
    }
  }
  
  static func missedTargetFeedback(){
    if let gameScene = currentGame.gameScene {
      gameScene.run(SKAction.run({
        Sensory.audioNodes["incorrect"]!.run(SKAction.play())
      }))
      AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
  }
  
  static func addParticles(sprite:SKSpriteNode, emitterFile:String, duration:TimeInterval = 0){
    if let emitter = SKEmitterNode(fileNamed: emitterFile){
      let addEmitter = SKAction.run {
        sprite.addChild(emitter)
      }
      if duration > 0 {
        let wait = SKAction.wait(forDuration: duration)
        let removeEmitter = SKAction.run {
          emitter.removeFromParent()
        }
        sprite.run(SKAction.sequence([addEmitter,wait,removeEmitter]))
      }else{
        sprite.run(addEmitter)
      }
    }
  }
  
  static func applyFrequency() {
    let hz = Game.respActive ? Game.currentRespSettings.frequency : Game.currentTrackSettings.frequency
    //below will need a ternary querying transition into resp phase and that responds with a tonefile reference on respsettings
    let tone = Game.currentTrackSettings.toneFile
    if let gameScene = currentGame.gameScene {
      let tone = SKAction.playSoundFileNamed(tone, waitForCompletion: true)
      let wait = SKAction.wait(forDuration: 1/hz/2)
      let systemVal = UIScreen.main.brightness
      let decrease = SKAction.run({ UIScreen.main.brightness = systemVal * 0.975 })
      let increase = SKAction.run({ UIScreen.main.brightness = systemVal })
      let freqGroup = SKAction.group([increase, tone])
      let sequence = SKAction.sequence([wait, decrease, wait, freqGroup])
      
      gameScene.run(SKAction.repeatForever(sequence), withKey: "frequencyLoopTimer")
      currentGame.timer?.members.append("frequencyLoopTimer")
    }
  }  
  
}


