
import Foundation
import SpriteKit
import AudioToolbox
import UIKit
import CoreHaptics

struct Sensory {
  
  static var audioNodes: [String: SKAudioNode] = [
    "correct": SKAudioNode(fileNamed: "correct_sound"),
    "incorrect": SKAudioNode(fileNamed: "wrong_sound"),
    "streak": SKAudioNode(fileNamed: "streak_sound"),
    "blip": SKAudioNode(fileNamed: "radar_blip")
  ]
  
  static var freqToneActions: [String: SKAction] = [
    "freq1": SKAction.playSoundFileNamed("tone200hz", waitForCompletion: true),
    "freq2": SKAction.playSoundFileNamed("tone185hz", waitForCompletion: true),
    "freq3": SKAction.playSoundFileNamed("tone170hz", waitForCompletion: true),
    "freq4": SKAction.playSoundFileNamed("tone155hz", waitForCompletion: true),
    "freq5": SKAction.playSoundFileNamed("tone140hz", waitForCompletion: true)
  ]
  
  
  static var hapticEngine: CHHapticEngine?
  
  static var hapticPlayers: [String: CHHapticPatternPlayer] = [String: CHHapticPatternPlayer]()
  
  static func createHapticEngine(){
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { print("no haptic support"); return }
    do {
      self.hapticEngine = try CHHapticEngine()
      self.hapticEngine?.playsHapticsOnly = true
      try self.hapticEngine?.start()
    } catch {
      print("Error with creating haptic engine: \(error.localizedDescription)")
    }
    
    self.hapticEngine?.stoppedHandler = { reason in
      print("The engine stopped: \(reason)")
    }
    
    self.hapticEngine?.resetHandler = { [self] in
      print("The engine reset")
      do {
        try self.hapticEngine?.start()
      } catch {
        print("failed to restart the engine: \(error.localizedDescription)")
      }
    }
  }
    
  
  static func foundTargetsFeedback(foundTarget:Ball){
    let weakPop = SystemSoundID(1519)
    let strongPop = SystemSoundID(1520)

    switch Game.currentTrackSettings.phase {
    case 1,2:
      self.addParticles(sprite: foundTarget, emitterFile: "red_spark.sks")
      foundTarget.showBorder()
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      AudioServicesPlaySystemSound(strongPop)
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          self.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls(emitter: true)
      }
    case 3:
      foundTarget.showBorder()
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      AudioServicesPlaySystemSound(weakPop)
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          Sensory.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls()
      }
    case 4:
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      AudioServicesPlaySystemSound(weakPop)
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        foundTarget.run(SKAction.run({
          Sensory.audioNodes["correct"]?.run(SKAction.play())
        }))
        currentGame.incrementStatusBalls()
      }
    case 5:
      foundTarget.texture = Game.currentTrackSettings.targetTexture
      AudioServicesPlaySystemSound(weakPop)
      if currentGame.foundTargets == Game.currentTrackSettings.numTargets {
        currentGame.incrementStatusBalls()
      }
    default:
      break
    }
  }
  
  static func missedTargetFeedback(){
    let cancelled = SystemSoundID(1521)
    let vibration = SystemSoundID(kSystemSoundID_Vibrate)

    if let gameScene = currentGame.gameScene {
      switch Game.currentTrackSettings.phase {
      case 1,2:
        gameScene.run(SKAction.run({
          Sensory.audioNodes["incorrect"]!.run(SKAction.play())
        }))
        AudioServicesPlaySystemSound(vibration)
      case 3,4,5:
        gameScene.run(SKAction.run({
          Sensory.audioNodes["incorrect"]!.run(SKAction.play())
        }))
        AudioServicesPlaySystemSound(cancelled)
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
  
  static func blinkBall(ball:Ball, fadeOutBlock:SKAction = SKAction.run {}, count:Int = 3){
    Ball.blinkFlags.append(true)
    if let currentTexture = ball.texture{
      let setFlashTexture = SKAction.setTexture(Game.currentTrackSettings.flashTexture)
      let resetTexture = SKAction.setTexture(currentTexture)
      let resetAlpha = SKAction.run {
        ball.alpha = Game.currentTrackSettings.alpha
      }
      let resetSprite = SKAction.group([resetTexture, resetAlpha])
      let fadeOut = SKAction.group([SKAction.fadeOut(withDuration: 0.15), fadeOutBlock])
      let fadeIn = SKAction.fadeIn(withDuration: 0.15)
      let fadeSequence = SKAction.repeat(SKAction.sequence([fadeOut, fadeIn]), count: count)
      let blinkAction = SKAction.sequence([setFlashTexture, fadeSequence, resetSprite])
      let resetFlag = SKAction.run { Ball.blinkFlags.removeLast() }
      let wait = SKAction.wait(forDuration: Double.random(min: 0.5, max: 1))
      let resetSequence = SKAction.sequence([wait, resetFlag])
      let flagSequence = SKAction.sequence([blinkAction, resetSequence])
      ball.run(flagSequence, withKey: "blinkBall")
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
    let event = self.createHapticEvent(intensity: 0.5, sharpness: 1, relativeTime: 0, duration: 0)

     do{
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      Sensory.hapticPlayers["frequency"] = try self.hapticEngine?.makePlayer(with: pattern)
     }catch{
      print("Problem creating haptic pattern or player: \(error.localizedDescription)")
     }
    if let gameScene = currentGame.gameScene {
      let tone = self.freqToneActions["freq\(Game.currentTrackSettings.phase)"]!
      let haptic = SKAction.run {
        do {
          try Sensory.hapticPlayers["frequency"]?.start(atTime: 0)
        }catch{
          print("Failed to play pattern: \(error.localizedDescription)")
        }
      }
      let toneGroup = SKAction.group([tone,haptic])
      let wait = SKAction.wait(forDuration: 1/hz/2)
      let systemVal = UIScreen.main.brightness
      let decrease = SKAction.run({ UIScreen.main.brightness = systemVal * 0.975 })
      let increase = SKAction.run({ UIScreen.main.brightness = systemVal })
      let freqGroup = SKAction.group([increase, toneGroup])
      let sequence = SKAction.sequence([wait, decrease, wait, freqGroup])
      
      gameScene.run(SKAction.repeatForever(sequence), withKey: "frequencyLoopTimer")
      currentGame.timer?.members.append("frequencyLoopTimer")
    }
  }
  
  static func fadeScreen(){
    guard let gameScene = currentGame.gameScene else { return }
    for ball in Ball.members {
      ball.physicsBody = nil
    }
    gameScene.run(SKAction.colorize(with: SKColor.black, colorBlendFactor: 1, duration: 10))
    gameScene.run(SKAction.fadeOut(withDuration: 10))
  }
  
  static func createHapticEvent(isContinuous:Bool = false, intensity:Double, sharpness:Double, relativeTime:Double, duration:Double) -> CHHapticEvent {
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
    let event:CHHapticEvent
    if isContinuous {
      event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: relativeTime, duration: duration)
    }else{
      event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity,sharpness], relativeTime: relativeTime, duration: duration)
    }
    return event
  }
  
  static func prepareHaptics(){
    
    
  //Breathloop haptics
    for respSettings in Game.respSettingsArr {
    //BEGIN haptic testing
      var factor = 1.0
      var relativeInTimes = [respSettings.inDuration/(factor * 23)]
      var time = relativeInTimes.last!
    
      while time < respSettings.inDuration - 0.01 {
        relativeInTimes.append(time + respSettings.inDuration/(factor * 23))
        time = relativeInTimes.last!
        factor += 0.13
      }
      let minimumDelay = relativeInTimes.last! - relativeInTimes[relativeInTimes.count - 2]
      var relativeHoldTimes = [minimumDelay]
      time = minimumDelay
      while time < respSettings.inWait - 0.01 {
        relativeHoldTimes.append(time + minimumDelay)
        time = relativeHoldTimes.last!
      }
      var relativeOutTimes = [minimumDelay]
      time = minimumDelay
      while time < respSettings.outDuration - 0.01 {
        relativeOutTimes.append(time + respSettings.outDuration/(factor * 23))
        time = relativeOutTimes.last!
        factor -= 0.13
      }
      var inEvents = [CHHapticEvent]()
      var increment = (0.8-0.35)/Double(relativeInTimes.count)
      var paramVal = 0.35
      relativeInTimes.forEach({ relativeTime in
        inEvents.append(Sensory.createHapticEvent(isContinuous: false, intensity: paramVal, sharpness: paramVal, relativeTime: relativeTime, duration: 0))
        paramVal += increment
      })
      let holdEvents = relativeHoldTimes.map({ relativeTime in
        Sensory.createHapticEvent(isContinuous: false, intensity: 0.8, sharpness: 0.8, relativeTime: relativeTime, duration: 0)
      })
      increment = (0.8-0.35)/Double(relativeOutTimes.count)
      paramVal = 0.8
      var outEvents = [CHHapticEvent]()
      relativeOutTimes.forEach({ relativeTime in
        outEvents.append(Sensory.createHapticEvent(isContinuous: false, intensity: paramVal, sharpness: paramVal, relativeTime: relativeTime, duration: 0))
        paramVal -= increment
      })
    
      do{
        let inPattern = try CHHapticPattern(events: inEvents, parameterCurves: [])
        self.hapticPlayers["testIn\(respSettings.phase)"] = try self.hapticEngine?.makePlayer(with: inPattern)
        let holdPattern = try CHHapticPattern(events: holdEvents, parameterCurves: [])
        self.hapticPlayers["testHold\(respSettings.phase)"] = try self.hapticEngine?.makePlayer(with: holdPattern)
        let outPattern = try CHHapticPattern(events: outEvents, parameterCurves: [])
        self.hapticPlayers["testOut\(respSettings.phase)"] = try self.hapticEngine?.makePlayer(with: outPattern)
      }catch{
        print("problem with test pattern or player: \(error.localizedDescription)")
      }
    //END haptic testing
    
      let incrementalOutDuration = respSettings.outDuration/10
      let incrementalInDuration = respSettings.inDuration/10
      var hapticInEvents = [CHHapticEvent]()
      var hapticOutEvents = [CHHapticEvent]()
      var startTime:Double = 0
      var revStartTime:Double = respSettings.outDuration - incrementalOutDuration
      for i in stride(from: 0.3, to: 0.8, by: (0.8-0.3)/10) {
        let inEvent = Sensory.createHapticEvent(isContinuous: true, intensity: i, sharpness: i, relativeTime: startTime, duration: incrementalInDuration)
        let outEvent = Sensory.createHapticEvent(isContinuous: true, intensity: i, sharpness: i, relativeTime: revStartTime, duration: incrementalOutDuration)
        startTime = startTime + incrementalInDuration
        revStartTime = revStartTime - incrementalOutDuration
        hapticInEvents.append(inEvent)
        hapticOutEvents.append(outEvent)
      }
      let holdEvent = Sensory.createHapticEvent(isContinuous: true, intensity: 0.8, sharpness: 0.8, relativeTime: 0, duration: respSettings.inWait)
         
      do{
        let holdPattern = try CHHapticPattern(events: [holdEvent], parameters: [])
        Sensory.hapticPlayers["breathHold\(respSettings.phase)"] = try Sensory.hapticEngine?.makePlayer(with: holdPattern)
        let inPattern = try CHHapticPattern(events: hapticInEvents, parameters: [])
        Sensory.hapticPlayers["breathIn\(respSettings.phase)"] = try Sensory.hapticEngine?.makePlayer(with: inPattern)
        let outPattern = try CHHapticPattern(events: hapticOutEvents, parameters: [])
        Sensory.hapticPlayers["breathOut\(respSettings.phase)"] = try Sensory.hapticEngine?.makePlayer(with: outPattern)
      }catch{
        print("error creating haptic pattern or player: \(error.localizedDescription)")
      }
    }
  }
}


