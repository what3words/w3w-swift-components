//
//  AppDelegate.swift
//  TextField
//
//  Created by Dave Duprey on 26/11/2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let uiTestingKeyPrefix = "UI-TestingKey_"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
      
      if AppDelegate.isUITestingEnabled {
          setUserDefaults()
      }
      
      return true
  }
    
    static var isUITestingEnabled: Bool {
        get {
            return ProcessInfo.processInfo.arguments.contains("UI-Testing")
        }
    }
    func resetDefaults()
    {
        let clipping  = ["Clipping", "ApiKey"]
        for clip in clipping {
            if (UserDefaults.standard.string(forKey: clip) != nil)
            {
                UserDefaults.standard.removeObject(forKey: clip)
            }
        }
    }
      
  private func setUserDefaults() {
      resetDefaults()
      for (key, value)
          in ProcessInfo.processInfo.environment
            where key.hasPrefix(AppDelegate.uiTestingKeyPrefix) {
                let userDefaultsKey = key.truncateUITestingKey()
                UserDefaults.standard.set(value, forKey: userDefaultsKey)
//
      }
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }


    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}

extension String {
    func truncateUITestingKey() -> String {
        if let range = self.range(of: AppDelegate.uiTestingKeyPrefix) {
            let userDefaultsKey = self[range.upperBound...]
            return String(userDefaultsKey)
        }
        return self
    }
}



