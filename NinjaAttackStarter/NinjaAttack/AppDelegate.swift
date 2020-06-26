

import UIKit
import Firebase
import AVFoundation
import MopinionSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    MopinionSDK.load("0ahuhmywb3yfzd8kjhli9pf1zg389btomnk", true)
    
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

