//
//  LoginViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit


class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    fileprivate var currentNonce: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let siwaButton = ASAuthorizationAppleIDButton()
        
        // set this so the button will use auto layout constraint
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add the button to the view controller root view
        self.view.addSubview(siwaButton)
        
        // set constraint
        NSLayoutConstraint.activate([
            siwaButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            siwaButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            siwaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            siwaButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        // the function that will be executed when user tap the button
        siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    @objc func appleSignInTapped() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
        
        // Generate nonce for validation after authentication successful
        self.currentNonce = randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(currentNonce!)
        
        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

    }
    
    
    
//    @IBAction func signInAppleUser(_ sender: GIDSignInButton) {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
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
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("complete")
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")

            guard let nonce = currentNonce else {
                self.presentErrorAlert(with: "Uh oh! We recieved an error during the login! Pleaes try again later!")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {

                self.presentErrorAlert(with: "Uh oh! We recieved an error during the login! Pleaes try again later!")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {

                self.presentErrorAlert(with: "Uh oh! We recieved an error during the login! Pleaes try again later!")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    self.presentErrorAlert(with: "We recieved an error during the login! Pleaes try again later!")
                    return
                }
                print("signed in!")
                // User is signed in to Firebase with Apple.
                // ...
            }
        }
    }
    
    
    @IBAction func signInUser(_ sender: GIDSignInButton) {
        print("in")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                
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
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
