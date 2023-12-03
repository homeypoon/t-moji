//
//  SettingsTableViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//


import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class SettingsTableViewController: UITableViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @objc(presentationAnchorForAuthorizationController:) func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            break
        case .unknown:
            // user didn't login their Apple ID on the device
            break
        case .invalidResponse:
            // invalid response received from the login
            self.presentErrorAlert(with: "Uh oh! We recieved an invalid response from the login!")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            self.presentErrorAlert(with: "Uh oh! We recieved an error during the login!")
        case .failed:
            // authorization failed
            self.presentErrorAlert(with: "Uh oh! We recieved an error during the login!")
        case .notInteractive:
            break
        @unknown default:
            break
        }
    }

    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: Notification.Name("NetworkStatusChanged"), object: nil)
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool, !isConnected {
            // The app is offline, present the OfflineViewController

            DispatchQueue.main.async {
                let offlineVC = self.storyboard?.instantiateViewController(withIdentifier: "OfflineViewController") as! OfflineViewController
                offlineVC.modalPresentationStyle = .fullScreen
                self.present(offlineVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
            do {
              try Auth.auth().signOut()
            } catch let signOutError as NSError {
                self.presentErrorAlert(with: signOutError.localizedDescription)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteUserPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Account?", message: "This action is irreversible! You will need to login to delete your account.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
            self.deleteCurrentUser()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteCurrentUser() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
      else {
        print("Unable to retrieve AppleIDCredential")
        return
      }

      guard let _ = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }

      guard let appleAuthCode = appleIDCredential.authorizationCode else {
        print("Unable to fetch authorization code")
        return
      }

      guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
        print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
        return
      }
        
        print(authCodeString)
        
        let user = Auth.auth().currentUser

      Task {
        do {
          try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            try await user?.delete()
        } catch {
            self.presentErrorAlert(with: "Delete account failed. Please try again!")
        }
      }
    }
        
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
          self.presentErrorAlert(with: "Uh oh! We recieved an error! Pleaes try again later!")
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    

}
