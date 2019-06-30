
import Foundation
import SpriteKit


struct Sensory {
  
  static func applyFrequency() {
    let hz = Game.currentSettings.frequency
    let tone = Game.currentSettings.toneFile
    if let gameScene = currentGame.gameScene {
      let tone = SKAction.playSoundFileNamed(tone, waitForCompletion: false)
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

