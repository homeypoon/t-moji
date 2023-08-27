//
//  QuizDetailViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds


class QuizDetailViewController: UIViewController {
    
    var quiz: Quiz?
    var currentUser: User!
    var quizHistory: QuizHistory!
    var quizCompleteState: Bool = false
    var currentUserResultType: ResultType?
    var takenByText: String!
    
    private var rewardedAd: GADRewardedAd?
    
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var resultGroupButton: UIButton!
    @IBOutlet var myResultLabel: UILabel!
    @IBOutlet var resultDetailButton: UIButton!
    @IBOutlet var takeQuizButton: UIButton!
    @IBOutlet var guessForTmatesButton: UIButton!
    @IBOutlet var quizDetailStackView: UIStackView!
    
    
    @IBOutlet var quizButtons: [UIButton]!
    
    var isRetakeQuiz: Bool?
    
    
    
    @IBOutlet var resultStackView: UIStackView!
    var takeQuizState: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        fetchQuizHistory()
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonFont()
    }
    
    func loadRetakeQuizRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-3940256099942544/1712485313",
                           request: request,
                           completionHandler: { [self] ad, error in
          if let error = error {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
            return
          }
          rewardedAd = ad
            showRetakeQuizRewardedAd()
          print("Rewarded ad loaded.")
        }
        )
      }
    
    func showRetakeQuizRewardedAd() {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self) {
                // Reward the user by letting them redo quiz
                self.performSegue(withIdentifier: "showPersonalQuiz", sender: nil)
            }
        } else {
            // Ad wasn't ready
            self.presentErrorAlert(withTitle: "No videos available 😔", withMessage: "Try again soon!")
        }
    }
    
    private func updateUIText() {
        
        print("updating uitext")
        print("self \(currentUserResultType)")
        guard let userID = Auth.auth().currentUser?.uid else { return }
        takeQuizState = quizHistory.completedUsers.contains(userID) ? ButtonState.retakeQuiz : ButtonState.takeQuiz
        
        if takeQuizState == ButtonState.takeQuiz {
            myResultLabel.isHidden = true
            resultDetailButton.isHidden = true
            resultStackView.isHidden = true
            
            takeQuizButton.setImage(nil, for: [])
            takeQuizButton.setTitle("Take Quiz", for: [])
            
        } else if takeQuizState == ButtonState.retakeQuiz {
            myResultLabel.isHidden = false
            resultDetailButton.isHidden = false
            resultStackView.isHidden = false
            
            myResultLabel.text = "My Result: \(currentUserResultType?.emoji ?? " ")"
            takeQuizButton.setTitle("  Retake Quiz", for: [])
            takeQuizButton.setImage(UIImage(systemName: "play.square.fill"), for: [])
        }
        
        quizTitleLabel.text = quiz?.title
        
//        // If no t-mates have taken quiz
//        if takenByText == TakenByText.noTmates {
//            guessForTmatesButton.isUserInteractionEnabled = false
//
//            guessForTmatesButton.tintColor = .systemGray2
//            print("truee")
//        } else {
//            guessForTmatesButton.isEnabled = true
//            guessForTmatesButton.tintColor = UIColor.systemCyan
//            print("false")
//        }
        guessForTmatesButton.configuration?.subtitle = takenByText
        
        quizDetailStackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 30, right: 20)
        quizDetailStackView.isLayoutMarginsRelativeArrangement = true
        
        quizDetailStackView.applyRoundedCornerAndShadow(borderType: .quizDetailBanner)
    }
    
    private func updateButtonFont() {
        for button in quizButtons {
            button.applyRoundedCornerAndShadow(borderType: .quizDetailButton)
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
                return outgoing
            }
        }
        
        resultGroupButton.setTitle(quiz?.resultGroup.rawValue.capitalized, for: [])
        
        resultGroupButton.tintColor = UIColor(named: "primaryLightRed")
        resultGroupButton.layer.borderColor = UIColor(named: "primaryRed")?.cgColor
        
        resultGroupButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            outgoing.foregroundColor = UIColor(named: "primaryRed")
            return outgoing
        }
    }
    
    @IBAction func showQuiz(_ sender: UIButton) {
        
        isRetakeQuiz = takeQuizState == ButtonState.retakeQuiz
        
        if let isRetakeQuiz = isRetakeQuiz {
            if isRetakeQuiz {
                // UNCOMMENT
//                loadRetakeQuizRewardedAd()

                self.performSegue(withIdentifier: "showPersonalQuiz", sender: nil) // delete
                
                
//                showRetakeQuizRewardedAd()
            } else {
                self.performSegue(withIdentifier: "showPersonalQuiz", sender: nil)
            }
        }
    }
    
    @IBAction func guessForTmatesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "selectMember", sender: nil)
    }
    
    
    func presentRetakeAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        // add watch ad to redo
        
        present(alert, animated: true, completion: nil)
    }
    
    func fetchQuizHistory() {
        guard let quizID = quiz?.id else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quizID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(withMessage: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.quizHistory = try document.data(as: QuizHistory.self)
                        print("q \(self.quizHistory)")
                        DispatchQueue.main.async { // Ensure UI updates are on the main thread
                            self.updateUIText()
                            self.updateButtonFont()
                            print("updating")
                        }
                    } catch {
                        self.presentErrorAlert(withMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                print("result type \(user)")
                self.currentUserResultType = user.userQuizHistory.first(where: { $0.quizID == self.quiz?.id })?.finalResult
                print("currentUserResultType")
                self.updateUIText()
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    func presentErrorAlert(withTitle title: String? = "Error", withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func seeResultDetailsPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showResultDetails", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showPersonalQuiz" {
            let personalQuizVC = segue.destination as! PersonalQuizViewController
            personalQuizVC.isRetakeQuiz = isRetakeQuiz
            personalQuizVC.currentUser = currentUser
            personalQuizVC.quiz = quiz
        } else if segue.identifier == "showResultDetails" {
            let navController = segue.destination as! UINavigationController
            let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
            quizResultVC.quiz = self.quiz
            quizResultVC.resultUser = self.currentUser
            
            quizResultVC.userQuizHistory = currentUser.userQuizHistory.first(where: { $0.quizID == self.quiz?.id })
            
            quizResultVC.quizResultType = .checkOwnResult
            
        } else if segue.identifier == "selectMember" {
            let selectMemberVC = segue.destination as! SelectMemberCollectionViewController
            selectMemberVC.quiz = quiz
            selectMemberVC.currentUser = currentUser
            selectMemberVC.quizHistory = quizHistory
        }
    }
    
}

extension QuizDetailViewController: GADFullScreenContentDelegate {
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
