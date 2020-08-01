

import UIKit
import Firebase
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    if currentGame.isRunning { currentGame.pauseGame()}
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {

    Sensory.createHapticEngine()
    if currentGame.isRunning{
      do {
        print("restarting engine")
        try Sensory.hapticEngine?.start()
      }catch{
        print(error.localizedDescription)
      }
      Sensory.applyFrequency()
      currentGame.unpauseGame()
    }
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    Sensory.createHapticEngine()
    if currentGame.isRunning{
      do {
        print("restarting engine")
        try Sensory.hapticEngine?.start()
      }catch{
        print(error.localizedDescription)
      }
      Sensory.applyFrequency()
    }
  }
  

}

