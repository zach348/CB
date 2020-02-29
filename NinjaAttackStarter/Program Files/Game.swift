
import Foundation
import SpriteKit
import Firebase

class Game {
      
  static var settingsArr:[Settings] = Settings.settings[DiffSetting.Easy]! {
    didSet {
      self.currentTrackSettings = settingsArr[0]
    }
  }

  static var respSettingsArr:[RespSettings] = [
    RespSettings(phase: 7, phaseDuration: 60, frequency: 4, inDuration: 3, inWait: 1.5, outDuration: 6, outWait: 2, moveToCenterDuration: 8.5, moveCenterWait: 2),
    RespSettings(phase: 8, phaseDuration: 120, frequency: 3.5, inDuration: 4, inWait: 2, outDuration: 8, outWait: 3.5, moveToCenterDuration: 8.5, moveCenterWait: 2),
    RespSettings(phase: 9, phaseDuration: 999, frequency: 3, inDuration: 5, inWait: 2.5, outDuration: 10, outWait: 5, moveToCenterDuration: 10, moveCenterWait: 2)
  ]
  static var willSaveGame:Bool = false
  static var didSaveGame:Bool = false
  static var respActive:Bool = false
  static var initialRespTransition = true
  ///STARTING POINTS
  static var currentRespSettings:RespSettings = respSettingsArr[0] {
    didSet {
      currentGame.advanceRespFlag = true
    }
  }
  static var currentTrackSettings:Settings = settingsArr[0] {
    didSet {
      //detection of final dummy phase (i.e,. phase '7') trips flag to begin transition into resp
      if self.currentTrackSettings.phase == 6 {
        self.respActive = true
        print("printing", Game.respActive)
      }
      if let timer = currentGame.timer, let worldTimer = currentGame.worldTimer {
        if self.respActive {
          self.transitionRespPhase(timer: timer, initial: true, worldTimer: worldTimer)
        }else{
          self.transitionTrackPhase(timer:timer)
        }
      }
    }
  }
  
  class func advancePhase(){
    guard let index = self.settingsArr.firstIndex(where: { setting in setting.phase == self.currentTrackSettings.phase + 1 }), let timer = currentGame.timer else {return}
      if !self.respActive && index < self.settingsArr.count {
        self.currentTrackSettings = self.settingsArr[index]
        timer.lastPhaseShiftTime = timer.elapsedTime
      }else if self.respActive{
        //do resp stuff here
        guard let respIndex = self.respSettingsArr.firstIndex(where: { respSetting in respSetting.phase == self.currentRespSettings.phase + 1 }) else { return }
        self.currentRespSettings = self.respSettingsArr[respIndex]
        timer.lastPhaseShiftTime = timer.elapsedTime
        if Game.currentRespSettings.phase == 8 { Sensory.fadeScreen() }
        print("Advanced resp phase")
      }
    
  }
  
  class func transitionTrackPhase(timer:Timer){
    currentGame.outcomeHistory.append(Outcome.transition)
    currentGame.streakAchieved = false
    currentGame.stagePoints = 0
    currentGame.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
    
    for (_, node) in Sensory.audioNodes {
      node.run(SKAction.changeVolume(by: Float(-0.245), duration: 0))
    }
    Sensory.applyFrequency()
    if(Game.currentTrackSettings.phase < 5){
      timer.targetTimer()
    }else{
      timer.stopTimer(timerID: "targetTimer")
    }
    if Ball.getTargets().count < Game.currentTrackSettings.numTargets && self.currentTrackSettings.phase < 6 {
      let numTargets = Game.currentTrackSettings.numTargets - Ball.getTargets().count
      for _ in 1...numTargets { Ball.addTarget()}
    }
    for ball in Ball.members {
      ball.border?.strokeColor = currentTrackSettings.borderColor
    }
    Ball.resetTextures()
    
    
    //testing
    
    //saving
    
  }
  
  class func transitionRespPhase(timer:Timer, initial:Bool = false, worldTimer:SKNode){
    //Remove phase advancement flag
    currentGame.advanceRespFlag = false
    //Refresh Frequency
    Sensory.applyFrequency()

    let circleAction:SKAction = initial ? SKAction.run({ timer.circleMovementTimer(initial: true)}) : SKAction.run({ timer.circleMovementTimer(initial: false)})
    //for transition from trackphase only
    if self.initialRespTransition {
      //Cleanup
      timer.members.forEach({ loop in
        if loop != "frequencyLoopTimer" && loop != "gameTimer"  && loop != "movementTimer" {timer.stopTimer(timerID: loop)}
      })
      for ball in Ball.getTargets(){
        Sensory.flickerOffTexture(sprite: ball, onTexture: Game.currentTrackSettings.targetTexture, offTexture: Game.currentTrackSettings.distractorTexture)
      }
      
      for statusBall in currentGame.statusBalls {
        Sensory.flickerOffAlpha(sprite: statusBall, startingAlpha: statusBall.alpha, endingAlpha: 0)
      }
      
      //Prep
      timer.breathLabel.fontColor = SKColor.black
      timer.breathLabel.fontSize = 30
      timer.breathLabel.fontName = "AvenirNext-Bold"
      timer.breathLabel.position.x = currentGame.gameScene!.size.width / 2
      timer.breathLabel.position.y = currentGame.gameScene!.size.height / 2
      timer.breathLabel.zPosition = -0.50
      if let gameScene = currentGame.gameScene { gameScene.addChild(timer.breathLabel)}
      Sensory.prepareHaptics()
      
      //bleed speed and stop master movement timer prior to calling circleMovementTimer
      let bleedSpeed = SKAction.run {
        timer.bleedSpeedTimer()
      }
      let wait = SKAction.wait(forDuration: 5)
      let stopMovementTimer = SKAction.run({ timer.stopTimer(timerID: "movementTimer")})
      self.initialRespTransition = false
      worldTimer.run(SKAction.sequence([bleedSpeed,wait,stopMovementTimer,wait,circleAction]))
    }else{
      print("running non initial circleaction")
      worldTimer.run(SKAction.sequence([circleAction]))
    }
  }
  
  
  var isRunning:Bool = false
  var gameScene:GameScene?
  var timer:Timer?
  var worldTimer:SKNode?
  var spriteWorld:SKNode?
  var hrController:HRMViewController?
  var statusBalls = [SKSpriteNode]()
  //currently unused setting variable
  var missesRemaining = Game.currentTrackSettings.missesAllowed
  var quitLabel = SKLabelNode()
  var advanceRespFlag:Bool = false
  var diffSetting = DiffSetting.Easy {
    didSet {
      guard let settingsArr = Settings.settings[self.diffSetting] else {print("error switching diff");return}
      Game.settingsArr = settingsArr
      print("switched currentGame.diffSetting")
    }
  }
  var foundTargets = 0 {
    didSet {
      if self.foundTargets == Game.currentTrackSettings.numTargets {
        currentGame.stagePoints += 1
        currentGame.outcomeHistory.append(Outcome.success)
      }
    }
  }
  var streakAchieved = false {
    didSet {
      if streakAchieved {
        Sensory.streakAchievedFeedback()
      }
    }
  }
  var failedAttempt = false {
    didSet{
      if self.failedAttempt { currentGame.outcomeHistory.append(Outcome.failure) }
    }
  }
  var outcomeHistory = [Outcome]() {
    //implement different length histories for upregulation(3) and downregulation(2)
    didSet{
      if self.outcomeHistory.last != Outcome.transition{
        if self.outcomeHistory.count >= 2 {
          let last2Outcomes = self.outcomeHistory[self.outcomeHistory.count - 2..<self.outcomeHistory.count]
          if !last2Outcomes.contains(Outcome.success) && !last2Outcomes.contains(Outcome.transition){
            if Settings.diffMod > 0.5 { Settings.diffMod -= 0.1 }
            print("downregulated - targetSpeed: \(Game.currentTrackSettings.targetMeanSpeed) - activeSpeed: \(Game.currentTrackSettings.activeMeanSpeed)")
          }
        }
        if self.outcomeHistory.count >= 3 {
          let last3Outcomes = self.outcomeHistory[self.outcomeHistory.count - 3..<self.outcomeHistory.count]
          if !last3Outcomes.contains(Outcome.failure) && !last3Outcomes.contains(Outcome.pass) && !last3Outcomes.contains(Outcome.transition) {
            if Settings.diffMod < 1.5 { Settings.diffMod += 0.03 }
            print("upregulated - targetSpeed: \(Game.currentTrackSettings.targetMeanSpeed) - activeSpeed: \(Game.currentTrackSettings.activeMeanSpeed)")
          }
        }
      }
    }
  }
  
  var stagePoints = 0 {
    didSet{
      if stagePoints == Game.currentTrackSettings.requiredStreak { currentGame.streakAchieved = true }
    }
  }
  var isPaused:Bool {
    didSet {
      if let worldTimer = currentGame.worldTimer {
        if isPaused {
          Ball.enableInteraction()
          worldTimer.isPaused = true
        }else{
          Ball.disableInteraction()
          worldTimer.isPaused = false
        }
      }
    }
  }
  
  var bpm:Int = -1
  
  init(){
    self.isPaused = false
  }
  
  func setupGame(){
    let userData = DataStore.user
    //game cleanup
    self.cleanupGame()
    
    self.timer = Timer()
    self.worldTimer = SKNode()
    self.spriteWorld = SKNode()
    self.hrController = HRMViewController()
    DataStore.dummyRequest()
    Settings.diffMod = userData["diffMod"] as! CGFloat
    
    if let scene = self.gameScene {
      if let worldTimer = self.worldTimer, let spriteWorld = currentGame.spriteWorld {
        scene.addChild(worldTimer)
        scene.addChild(spriteWorld)
        spriteWorld.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
      }
      //gamescene formatting
      scene.backgroundColor = .lightGray
      scene.scaleMode = .aspectFit
      scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
      scene.physicsWorld.gravity = .zero
      scene.physicsWorld.contactDelegate = gameScene
      
      for (name, audioNode) in Sensory.audioNodes {
        audioNode.autoplayLooped = false
        if name == "blip" {audioNode.run(SKAction.changeVolume(by: -0.6, duration: 0))}
        scene.addChild(audioNode)
      }
      for (name, toneNode) in Sensory.toneNodes {
        toneNode.autoplayLooped = false
        scene.addChild(toneNode)
      }
      
      self.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
      
      //stimuli
      self.gameScene!.view!.frame.width < 670 ? Ball.createBalls(num: 10, game: self) : Ball.createBalls(num: 12, game: self)
      Tile.createTiles()
      self.addMemberstoScene(collections: [Ball.members, Tile.members])
    }
  }
  
  func startGame(){
    if let masterTimer = currentGame.timer {
      masterTimer.startGameTimer()
      Ball.startMovement()
      self.timer?.startTimerActions()
      Sensory.applyFrequency()
      self.isRunning = true
    }
  }
  
  func cleanupGame(){
    Sensory.createHapticEngine()
    Ball.members = [Ball]()
    Ball.blinkFlags = [Bool]()
    Ball.pendingPause = false
    Ball.pendingShift = false
    Ball.assignedBlinkAudio = false
//    leftover from nonpersistent diffMods
//    Settings.diffMod = 1
    Game.willSaveGame = false
    Game.didSaveGame = false
    Game.respActive = false
    Game.initialRespTransition = true
    Game.currentRespSettings = Game.respSettingsArr[0]
    Game.currentTrackSettings = Game.settingsArr[0]
    Tile.members = [Tile]()
    DataStore.currentUser = Auth.auth().currentUser
    DataStore.initialRequest = true
    DataStore.db = Firestore.firestore()
    DataStore.metaRef = DataStore.db.document("meta/gameMetaData")
    DataStore.records = [[String:Any]]()
    DataStore.eventMarkers = [
      "didShift": ["flag": false, "delay": -1],
      "didAttempt": ["flag": false, "success": -1, "stagePoints": -1]
    ]
    DataStore.ballInfo = [[String:Any]]()
    Sensory.audioNodes = [
      "correct": SKAudioNode(fileNamed: "correct_sound"),
      "incorrect": SKAudioNode(fileNamed: "wrong_sound"),
      "streak": SKAudioNode(fileNamed: "streak_sound"),
      "blip": SKAudioNode(fileNamed: "radar_blip"),
      "robot_blip": SKAudioNode(fileNamed: "Robot_blip"),
      "test": SKAudioNode(fileNamed: "Untitled")
    ]
    Sensory.toneNodes = [
      "tone1": SKAudioNode(fileNamed: "tone200hz.wav"),
      "tone2": SKAudioNode(fileNamed: "tone185hz.wav"),
      "tone3": SKAudioNode(fileNamed: "tone170hz.wav"),
      "tone4": SKAudioNode(fileNamed: "tone155hz.wav"),
      "tone5": SKAudioNode(fileNamed: "tone140hz.wav"),
      "tone6": SKAudioNode(fileNamed: "tone140hz.wav"),
      "tone7": SKAudioNode(fileNamed: "tone140hz.wav")
    ]
  }
  
  func pauseGame(){
    
    
    //implementation
    if !Ball.blinkFlags.isEmpty {
      Ball.pendingPause = true
      return
    }
    if let timer = self.timer {
      self.isPaused = true
      Ball.freezeMovement()
      Ball.maskTargets()
      Ball.resetFoundTargets()
      currentGame.foundTargets = 0
      currentGame.failedAttempt = false
      //irrelevant for now
      currentGame.missesRemaining = Game.currentTrackSettings.missesAllowed
      //
      timer.pauseCountdown()
      //testing
    }
  }
  
  func unpauseGame(){
    if !self.failedAttempt && self.foundTargets < Game.currentTrackSettings.numTargets { currentGame.outcomeHistory.append(Outcome.pass)}
    self.isPaused = false
    Ball.removeEmitters()
    Ball.unfreezeMovement()
    Ball.unmaskTargets()
    Ball.hideBorders()
    Ball.resetTextures()
  }
  
  func resetStatusBalls(){
    self.createStatusBalls(num: Game.currentTrackSettings.requiredStreak)
  }
  
  func incrementStatusBalls(emitter:Bool = false) {
    for ball in self.statusBalls {
      if ball.texture!.description == "<SKTexture> 'sphere-black' (256 x 256)" {
        ball.run(SKAction.setTexture(SKTexture(imageNamed: "sp-darkYellow-gloss")))
        if emitter { Sensory.addParticles(sprite: ball, emitterFile: "ball_fire")}
        return
      }
    }
  }
  
  func decrementStatusBalls(){
    if(self.stagePoints > 0){
      let streakArr = self.statusBalls.filter { statusBall in
        statusBall.texture!.description == "<SKTexture> 'sp-darkYellow-gloss' (1500 x 1502)"
      }
      for node in streakArr.last!.children {
        if node is SKEmitterNode { node.removeFromParent() }
      }
      streakArr.last!.run(SKAction.setTexture(SKTexture(imageNamed: "sphere-black")))
    }
  }
  
  private
  
  func addMemberstoScene(collections: [[SKNode]]){
    if let spriteWorld = self.spriteWorld {
      for collection in collections {
        for sprite in collection{
          spriteWorld.addChild(sprite)
        }
      }
    }
  }
  
  func createStatusBalls(num:Int){
    self.statusBalls.forEach({ball in ball.removeFromParent()})
    self.statusBalls = [SKSpriteNode]()
    if let gameScene = currentGame.gameScene {
      for _ in 1...num {
        let xPosition = self.statusBalls.isEmpty ? gameScene.size.width / 15 : self.statusBalls.last!.position.x + 20
        let statusBall = SKSpriteNode(imageNamed: "sphere-black")
        statusBall.size = CGSize(width: 15, height: 15)
        statusBall.zPosition = -1
        statusBall.position.x = xPosition
        statusBall.position.y = gameScene.size.height / 9 * 8
        self.statusBalls.append(statusBall)
        gameScene.addChild(statusBall)
      }
    }
  }
}

