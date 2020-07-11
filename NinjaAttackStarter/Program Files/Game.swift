
import Foundation
import SpriteKit
import Firebase
import AVFoundation

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
  static var respActive:Bool = false {
    didSet {
      if respActive {
        guard let completedGames = DataStore.user["completedGamesCount"] as? Int else { print("error getting current user (respActive observer)"); return }
        DataStore.user["completedGamesCount"] = completedGames + 1
      }
    }
  }
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
        if Game.currentRespSettings.phase == 8 {
          Sensory.fadeScreen()
          if Survey.willDeployPrePostSurvey {
            let wait = SKAction.wait(forDuration: 20)
            let deployPostSurvey = SKAction.run {
              if let gvc =  currentGame.gameScene?.gameViewController, let postHash = Survey.surveys["activePost"], let postHashString = postHash as? String {
                Survey.presentSurvey(surveyHash: postHashString, gvc: gvc)
              }
             }
            let stopAction = SKAction.run {
                timer.stopTimers(timerArray: ["breathLoop", "frequencyLoopTimer"])
                Sensory.hapticEngine = nil
            }
            let sequence = SKAction.sequence([wait,stopAction,deployPostSurvey])
            if let gameScene = currentGame.gameScene { gameScene.run(sequence)}
          }
        }
        print("Advanced resp phase")
      }
    
  }
  
  class func transitionTrackPhase(timer:Timer){
    currentGame.appendTransition()
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
      timer.stopTimers(timerArray: ["targetTimer"])
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
        if loop != "frequencyLoopTimer" && loop != "gameTimer"  && loop != "movementTimer" && loop != "saveTimer" && loop != "dataTimer" {timer.stopTimers(timerArray: [loop])}
      })
      for ball in Ball.getTargets(){
        Sensory.flickerOffTexture(sprite: ball, onTexture: Game.currentTrackSettings.targetTexture, offTexture: Game.currentTrackSettings.distractorTexture)
        ball.isTarget = false
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
      let stopMovementTimer = SKAction.run({ timer.stopTimers(timerArray: ["movementTimer"])})
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
  var pauseCountdownTimerLabel = SKLabelNode()
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
        currentGame.appendSuccess()
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
            if Settings.diffMod < 1.5 { Settings.diffMod += 0.04 }
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
//    guard let user = Auth.auth().currentUser, let email = user.email else { return }
//    DataStore.getUser(userId: email)
    //game cleanup
    self.cleanupGame()
    
    self.timer = Timer()
    self.worldTimer = SKNode()
    self.spriteWorld = SKNode()
    self.hrController = HRMViewController()
    DataStore.dummyRequest()
    
    
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
      DataStore.initiateGame()

      masterTimer.startGameTimer()
      Ball.startMovement()
      masterTimer.startTimerActions()
      Sensory.applyFrequency()
      self.isRunning = true
      
      print(Game.currentTrackSettings.phase)
    }
  }
  
  func cleanupGame(){
    self.setupNotifications()
    


    Ball.members = [Ball]()
    Ball.blinkFlags = [Bool]()
    Ball.pendingPause = false
    Ball.pendingShift = false
    Ball.assignedBlinkAudio = false
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
    DataStore.metaGameRef = DataStore.db.document("meta/gameMeta")
    DataStore.records = [[String:Any]]()
    DataStore.eventMarkers = [
      "didShift": ["flag": false, "delay": -1],
      "didAttempt": ["flag": false, "success": -1, "stagePoints": -1]
    ]
    DataStore.ballInfo = [[String:Any]]()
    DataStore.gameCount = 0
    DataStore.tpCount = 1
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
    
    
    Sensory.unregisterAudioResources()
    Sensory.soundResourcesRegistered = false
    Sensory.createHapticEngine()
    Sensory.prepareAudioHaptics(volume: Game.currentTrackSettings.sfxVolume)
    
    Survey.updateSurveyStatus()
  }
  
  func pauseGame(){
    self.isPaused = true
    Ball.freezeMovement()
    
  }
  
  func unpauseGame(){
    self.isPaused = false
    Ball.unfreezeMovement()
  }
  
  func beginAttempt(){
    //implementation
    if !Ball.blinkFlags.isEmpty {
      Ball.pendingPause = true
      return
    }
    if let timer = self.timer {
      self.pauseGame()
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
  
  func endAttempt(){
    if !self.failedAttempt && self.foundTargets < Game.currentTrackSettings.numTargets { currentGame.appendPass()}
    Ball.removeEmitters()
    Ball.unmaskTargets()
    Ball.hideBorders()
    Ball.resetTextures()
    self.unpauseGame()
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
  
  func appendPass(){
    
    self.outcomeHistory.append(Outcome.pass)
  }
  
  func appendSuccess(){
    self.outcomeHistory.append(Outcome.success)
  }
  
  func appendFailure(){
    self.outcomeHistory.append(Outcome.failure)
  }
  
  func appendTransition(){
    self.outcomeHistory.append(Outcome.transition)
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
  
  func setupNotifications() {
      // Get the default notification center instance.
      let nc = NotificationCenter.default
      nc.addObserver(self,
                     selector: #selector(handleInterruption),
                     name: AVAudioSession.interruptionNotification,
                     object: nil)
  }

  @objc func handleInterruption(notification: Notification) {
      // To be implemented.
//    Sensory.hapticsRunning = false
    print("interruption!!!")
    print("-----------")
    for (name, node) in Sensory.audioNodes {
      node.run(SKAction.stop())
    }
  }
    
}

