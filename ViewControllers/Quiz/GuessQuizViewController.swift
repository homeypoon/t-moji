//
//  MemberQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleMobileAds

class GuessQuizViewController: UIViewController, ExtraGuessPopupViewDelegate {
    func noThanksButtonClicked() {
        
        removeBlurEffect()
        updateUserWithPointsAndGuessCount {

            self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
        }
    }
    
    func extraGuessGranted() {
        showExtraGuessRewardAd()
        removeBlurEffect()
    }
    
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var quizQuestionLabel: UILabel!
    @IBOutlet var multiChoiceButton1: UIButton!
    @IBOutlet var multiChoiceButton2: UIButton!
    @IBOutlet var multiChoiceButton3: UIButton!
    @IBOutlet var multiChoiceButton4: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var multiChoiceButtons: [UIButton]!
    
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    var fromResultVC: Bool?
    
    var quiz: Quiz?
    var group: Group?
    var userQuizHistory: UserQuizHistory?
    var members = [User]()
    var guessedMember: User?
    
    var guessedResultType: ResultType! // selected by user
    
    var previousWrongSelectedButton: UIButton?
    
    var resultChoices: [ResultType] = []
    var selectedButton: UIButton?
    
    var blurEffectView: UIVisualEffectView?

    @IBOutlet var extraGuessPopupView: ExtraGuessPopupView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
//        extraGuessPopupView.isHidden = true
        extraGuessPopupView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extraGuessPopupView.delegate = self
        
        updateUI()
        loadGuessRewardedAd()
    }
    
    private func loadGuessRewardedAd() {
        
        GADRewardedInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/6978759866",
            request: GADRequest()) { ad, error in
              if let error = error {
                  return
              }

              self.rewardedInterstitialAd = ad
              self.rewardedInterstitialAd?.fullScreenContentDelegate = self
            }
    }
    
    func showExtraGuessRewardAd() {
      guard let rewardedInterstitialAd = rewardedInterstitialAd else {
        presentErrorAlert(with: "The video wasn't available, but you still get another guess!")
          loadGuessRewardedAd()
          return
      }

      rewardedInterstitialAd.present(fromRootViewController: self) {
        // TODO: Reward the user!
          self.updateUI()
          self.loadGuessRewardedAd()
      }
    }
    

    func updateUI() {
        for button in multiChoiceButtons {
            if button == previousWrongSelectedButton {
                button.isEnabled = false
            }
            
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
            
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 24, weight: .medium)
                return outgoing
            }
            
            button.applyRoundedCornerAndShadow(borderType: .quizButton)
            
            button.titleLabel?.textAlignment = .center
        }
        
        submitButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            return outgoing
        }
        
        submitButton.tintColor = UIColor(named: "primaryRed")
        submitButton.setTitleColor(UIColor(named: "white"), for: [])
        
        submitButton.applyRoundedCornerAndShadow(borderType: .guessSubmitButton)

        if let quizHistory = userQuizHistory,
           let member = guessedMember {
            
            if let quiz = QuizData.quizzes.first(where: { $0.id == quizHistory.quizID }) {
                self.quiz = quiz
                quizTitleLabel.text = "\(quiz.title)"
                quizQuestionLabel.text = "Which \(quiz.resultGroup.rawValue) do you think \(member.username) got?"
            }
            
            let finalResult = quizHistory.finalResult


            for (_, types) in ResultType.groupedTypes {
                if types.contains(finalResult) {
                    var types = types.shuffled()
                    if let finalResultIndex = types.firstIndex(of: finalResult) {
                        types.remove(at: finalResultIndex)
                    }
                    resultChoices = ([finalResult] + Array(types.prefix(3))).shuffled()

                    // Set title of the mc buttons
                    multiChoiceButton1.setTitle("\(resultChoices[0].rawValue.capitalized) \(resultChoices[0].emoji)", for: [])
                    multiChoiceButton2.setTitle("\(resultChoices[1].rawValue.capitalized) \(resultChoices[1].emoji)", for: [])
                    multiChoiceButton3.setTitle("\(resultChoices[2].rawValue.capitalized) \(resultChoices[2].emoji)", for: [])
                    multiChoiceButton4.setTitle("\(resultChoices[3].rawValue.capitalized) \(resultChoices[3].emoji)", for: [])
                    
                }
                
            }
        }
        
    }
    
    @IBAction func multiChoiceButtonTapped(_ sender: UIButton) {
        // Reset the color of all buttons
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
        }
        
        // Set the selected button's color
        sender.tintColor = UIColor(named: "primaryDarkOrange")
        sender.setTitleColor(UIColor(named: "white"), for: [])
        
        selectedButton = sender
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        guard selectedButton != nil else { return }
        
        switch selectedButton {
        case multiChoiceButton1:
            guessedResultType = resultChoices[0]
        case multiChoiceButton2:
            guessedResultType = resultChoices[1]
        case multiChoiceButton3:
            guessedResultType = resultChoices[2]
        case multiChoiceButton4:
            guessedResultType = resultChoices[3]
        default:
            break
        }
        
        // If user retried guess already, show guess results
        if previousWrongSelectedButton != nil {
            
            updateUserWithPointsAndGuessCount {}
            
            self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
            
        } else {
            // If user is correct, perform segue
            if guessedResultType == userQuizHistory?.finalResult {
                updateUserWithPointsAndGuessCount {
                    self.updateGuessedMembers {
                        self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
                    }
                }
            } else {
                // Show extra guess pop up
                self.navigationItem.hidesBackButton = true
                
                previousWrongSelectedButton = selectedButton
                
                showExtraGuessPopup()
                
                extraGuessPopupView.restartCountdown()
                
                self.updateGuessedMembers { }
                
                selectedButton = nil
            }
        }
    }
    
    func updateGuessedMembers(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion()
            return }
        
        if let quizID = quiz?.id, var guessedMember = self.guessedMember {
            if let index = guessedMember.userQuizHistory.firstIndex(where: { $0.quizID == quizID }) {
                var mutableUserQuizHistory = guessedMember.userQuizHistory[index]
                mutableUserQuizHistory.membersGuessed.append(userId)
                guessedMember.userQuizHistory[index] = mutableUserQuizHistory
                
                // Assign the modified guessedMember back to the property
                self.guessedMember = guessedMember
            }
        }
        guard let guessedMemberID = guessedMember?.uid else {
            completion()
            return }
        
        let collectionRef = FirestoreService.shared.db.collection("users")
        do {
            try collectionRef.document(guessedMemberID).setData(from: self.guessedMember)
            completion()
        }
        catch {
            Helper.presentErrorAlert(on: self, with: error.localizedDescription)
        }
    }
    
    private func updateUserWithPointsAndGuessCount(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(_):
                let points = self.guessedResultType == self.userQuizHistory?.finalResult ? Points.guessCorrect : Points.guessIncorrect
                
                if self.guessedResultType == self.userQuizHistory?.finalResult {
                    docRef.updateData([
                        "points": FieldValue.increment(Int64(points)),
                        "correctGuesses": FieldValue.increment(Int64(1))
                    ])
                } else {
                    docRef.updateData([
                        "points": FieldValue.increment(Int64(points)),
                        "wrongGuesses": FieldValue.increment(Int64(1))
                    ])
                }
               
                completion()
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
                completion()
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "submitMemberQuiz" else { return }
        
        let navController = segue.destination as! UINavigationController
        let guessResultVC = navController.topViewController as! GuessResultCollectionViewController
        
        guessResultVC.modalPresentationStyle = .fullScreen

        
        guessResultVC.group = self.group
        guessResultVC.quiz = self.quiz
        guessResultVC.members = self.members
        guessResultVC.guessedUser = self.guessedMember
        guessResultVC.userQuizHistory = self.userQuizHistory
        guessResultVC.guessedResultType = self.guessedResultType
        
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func showExtraGuessPopup() {
        addBlurEffect()
        view.addSubview(extraGuessPopupView)

        extraGuessPopupView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let blurEffectView = blurEffectView {
            self.view.addSubview(blurEffectView)
        }
    }
    
    func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
}

extension GuessQuizViewController: GADFullScreenContentDelegate {

  /// Tells the delegate that the ad failed to present full screen content.
  func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("Ad did fail to present full screen content.")
      presentErrorAlert(with: "The video wasn't available, but you still get another guess!")
      updateUI()
  }

  /// Tells the delegate that the ad will present full screen content.
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad will present full screen content.")
  }

  /// ad dismissed
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
  }
}


