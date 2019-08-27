
import Foundation
import SpriteKit
import AudioToolbox
import UIKit


struct Sensory {
  
  static var audioNodes: [String: SKAudioNode] = [
    "correct": SKAudioNode(fileNamed: "correct_sound"),
    "incorrect": SKAudioNode(fileNamed: "wrong_sound"),
    "streak": SKAudioNode(fileNamed: "streak_sound"),
    "blip": SKAudioNode(fileNamed: "radar_blip")
  ]
  
  static func foundTargetsFeedback(foundTarget:Ball){
    switch Game.currentTrackSettings.phase {
    case 1,2:
      self.addParticles(sprite: foundTarget, emitterFile: "red_spark.sks")
      foundTarget.showBorder()
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          self.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls(emitter: true)
      }
    case 3:
      foundTarget.showBorder()
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          Sensory.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls()
      }
    case 4:
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          Sensory.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls()
      }
    case 5:
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        currentGame.incrementStatusBalls()
      }
    default:
      break
    }
  }
  
  static func missedTargetFeedback(){
    if let gameScene = currentGame.gameScene {
      switch Game.currentTrackSettings.phase {
      case 1,2:
        gameScene.run(SKAction.run({
          Sensory.audioNodes["incorrect"]!.run(SKAction.play())
        }))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
      case 3,4:
        gameScene.run(SKAction.run({
          Sensory.audioNodes["incorrect"]!.run(SKAction.play())
        }))
      default:
        break
      }
    }
  }
  
  
  
  static func streakAchievedFeedback(){
    if let gameScene = currentGame.gameScene {
      switch Game.currentTrackSettings.phase {
      case 1,2,3,4:
        gameScene.run(SKAction.run({
          Sensory.audioNodes["streak"]?.run(SKAction.play())
        }))
      default:
        break
      }
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
  
  static func flickerOffTexture(sprite:SKSpriteNode, onTexture:SKTexture, offTexture:SKTexture, duration:TimeInterval = 0.75){
    let off = SKAction.setTexture(offTexture)
    let on = SKAction.setTexture(onTexture)
    let waitAction = SKAction.wait(forDuration: duration)
    if duration < 0.01 {
      sprite.run(off)
    }else{
      let newDuration = duration * Double.random(min: 0.85, max: 0.85)
      let recursiveCall = SKAction.run {
        self.flickerOffTexture(sprite: sprite, onTexture: onTexture, offTexture: offTexture, duration:newDuration)
      }
      sprite.run(SKAction.sequence([off,waitAction,on,waitAction]), completion: { sprite.run(recursiveCall)})
    }
  }
  
  static func flickerOffAlpha(sprite:SKSpriteNode, startingAlpha:CGFloat, endingAlpha:CGFloat, duration:TimeInterval = 0.75){
    let off = SKAction.fadeOut(withDuration: 0)
    let on = SKAction.fadeIn(withDuration: 0)
    let waitAction = SKAction.wait(forDuration: duration)
    if duration < 0.01 {
      sprite.run(off)
    }else{
      let newDuration = duration * Double.random(min: 0.85, max: 0.85)
      let recursiveCall = SKAction.run {
        self.flickerOffAlpha(sprite: sprite, startingAlpha: startingAlpha, endingAlpha: endingAlpha, duration:newDuration)
      }
      sprite.run(SKAction.sequence([off,waitAction,on,waitAction]), completion: { sprite.run(recursiveCall)})
    }
  }
  
  static func playRadarBlip(count:Int){
    if let gameScene = currentGame.gameScene {
      let playSound = SKAction.run({
        self.audioNodes["blip"]?.run(SKAction.play())
      })
      gameScene.run(SKAction.repeat(playSound, count: count))
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


