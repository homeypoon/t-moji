//
//  AppDelegate.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleMobileAds
import FirebaseFirestore
import Network

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let monitor = NWPathMonitor()
    let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Internet connection is available
                NotificationCenter.default.post(name: Notification.Name("NetworkStatusChanged"), object: nil, userInfo: ["isConnected": true])
            } else {
                    
                NotificationCenter.default.post(name: Notification.Name("NetworkStatusChanged"), object: nil, userInfo: ["isConnected": false])
            }
        }
        
        monitor.start(queue: networkQueue)
        
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let settings = FirestoreSettings()
        
        settings.cacheSettings =
        MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())
        
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        
        let db = Firestore.firestore()
        db.settings = settings
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
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
