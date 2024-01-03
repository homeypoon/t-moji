//
//  SceneDelegate.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import Firebase
import AuthenticationServices
import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    enum TabBarScreen: Int {
        case home = 0, explore = 1, leaderboard = 2, profile = 3
    }
    
    @objc func handleNetworkStatusChange(_ notification: Notification) {
        print("handle")
            if let isConnected = notification.userInfo?["isConnected"] as? Bool {
                if isConnected {
//                    DispatchQueue.main.async {
//                        print("scene delegate online")
//                        let offlineVC = self.storyboard.instantiateViewController(withIdentifier: "OfflineViewController")
//                        offlineVC.modalPresentationStyle = .fullScreen
//
//                        let appDelegate = UIApplication.shared.delegate
//                        appDelegate?.window??.addSubview(offlineVC.view)
//                        appDelegate?.window??.bringSubviewToFront(offlineVC.view)
//                    }
                } else {
                    DispatchQueue.main.async {
                        print("scene delegate offline")
                        if let windowScene = notification.object as? UIWindowScene {
                            
//                            let offlineVC = self.storyboard.instantiateViewController (withIdentifier: "LoginViewController") as! LoginViewController
//                            offlineVC.modalPresentationStyle = .fullScreen
//                            self.showScreen(viewController: offlineVC, windowScene: windowScene)
                        }
//                        let offlineVC = self.storyboard.instantiateViewController(withIdentifier: "OfflineViewController")
//                        offlineVC.modalPresentationStyle = .fullScreen
//
//                        let appDelegate = UIApplication.shared.delegate
//                        appDelegate?.window??.addSubview(offlineVC.view)
//                        appDelegate?.window??.bringSubviewToFront(offlineVC.view)
                    }
                }
            }
        }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetworkStatusChange(_:)), name: Notification.Name("NetworkStatusChanged"), object: windowScene)
        
        if let userID = UserDefaults.standard.string(forKey: "userID") {
                    
            // get the login status of Apple sign in for the app
            // asynchronous
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID, completion: {
                credentialState, error in

                switch(credentialState){
                case .authorized:
                    print("user remain logged in, proceed to another view")
                    let tabBarController = self.storyboard.instantiateViewController (withIdentifier: "TabBar") as! UITabBarController

                    tabBarController.selectedIndex = TabBarScreen.home.rawValue
                    self.showScreen(viewController: tabBarController, windowScene: windowScene)
                case .revoked:
                    print("user logged in before but revoked")
                case .notFound:
                    print("user haven't log in before")
                default:
                    print("unknown state")
                }
            })
        }
        
        // No internet connection
        
        // Check Firestore authentication status
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // User is authenticated, show the Home screen
            if user != nil {

                let tabBarController = self.storyboard.instantiateViewController (withIdentifier: "TabBar") as! UITabBarController

                tabBarController.selectedIndex = TabBarScreen.home.rawValue
                self.showScreen(viewController: tabBarController, windowScene: windowScene)
        
                
            } else {
                let loginVC = self.storyboard.instantiateViewController (withIdentifier: "LoginViewController") as! LoginViewController
                self.showScreen(viewController: loginVC, windowScene: windowScene)
            }
        }
        
    }
    
    // Show the corresponding screen
    func showScreen(viewController: UIViewController,windowScene: UIWindowScene) {
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        DispatchQueue.main.async {
        //User is on iOS 14/15.
        //Do what you need to do after you received permission
        }
        })
        } else {
        //User has a lower iOS version
        //Do whatever you want, you don't need any permission
        }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

