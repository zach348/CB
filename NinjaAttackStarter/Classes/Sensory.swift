
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
  
  static var emitterNodes: [String: SKEmitterNode] = [
    "streakParticles": SKEmitterNode(fileNamed: "spark")!
  ]
  
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


