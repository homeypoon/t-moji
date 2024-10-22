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
    var shadowLayer: CAShapeLayer!
    
    private var rewardedAd: GADRewardedAd?
    
    @IBOutlet var withResultQuizTitleLabel: UILabel!
    @IBOutlet var withoutResultQuizTitleLabel: UILabel!
    @IBOutlet var withResultResultGroupButton: UIButton!
    @IBOutlet var withoutResultResultGroupButton: UIButton!
    @IBOutlet var myResultLabel: UILabel!
    @IBOutlet var resultDetailButton: UIButton!
    @IBOutlet var takeQuizButton: UIButton!
    @IBOutlet var guessForTmatesButton: UIButton!
    
    @IBOutlet var withResultView: UIView!
    @IBOutlet var withoutResultView: UIView!
    
    
    @IBOutlet var quizButtons: [UIButton]!
    var loadingAlert: UIAlertController?
    var loadingIndicator: UIActivityIndicatorView?
    
    var isRetakeQuiz: Bool?
    
    var takeQuizState: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.takeQuizState = currentUserResultType != nil ? ButtonState.retakeQuiz : ButtonState.takeQuiz
        
        updateUIText()
        updateButtonFont()
        
        fetchQuizHistory() {
            self.fetchUser()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func loadRetakeQuizRewardedAd() {
        if loadingAlert == nil {
            loadingAlert = UIAlertController(title: nil, message: "Loading Video...", preferredStyle: .alert)
            
            loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator?.hidesWhenStopped = true
            loadingIndicator?.style = UIActivityIndicatorView.Style.medium
            loadingIndicator?.startAnimating()
        }
        
        if let loadingAlert = loadingAlert, let loadingIndicator = loadingIndicator {
            loadingAlert.view.addSubview(loadingIndicator)
            present(loadingAlert, animated: true, completion: nil)
        }
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-2315105541829350/8566828108",
                           request: request,
                           completionHandler: { [self] ad, error in
            if let error = error {
                //            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                if let vc = self.presentedViewController, vc is UIAlertController {
                    print("isalert")
                    dismiss(animated: false, completion: {
                        self.presentErrorAlert(withTitle: "No videos available 😔", withMessage: "Try again soon!")
                    })
                    print("dismissed")
                }
                
                return
            }
            rewardedAd = ad
            if let vc = self.presentedViewController, vc is UIAlertController {
                print("isalert")
                dismiss(animated: false, completion: {
                    self.showRetakeQuizRewardedAd()
                })
                print("dismissed")
            }
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
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if let existingShadowLayer = shadowLayer {
            existingShadowLayer.removeFromSuperlayer()
        }
        
        if takeQuizState == ButtonState.takeQuiz {
            withResultView.isHidden = true
            withoutResultView.isHidden = false
            withoutResultQuizTitleLabel.text = quiz?.title
            
            takeQuizButton.setImage(nil, for: [])
            takeQuizButton.setTitle("Take Quiz", for: [])
            
            updateResultGroupButton(resultGroupButton: withoutResultResultGroupButton)
            
            //            withoutResultView.applyRoundedCornerAndShadow(viewType: .quizDetailBanner)
            
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: withoutResultView.bounds, cornerRadius: 18.0).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.8, height: 0.8)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 2.5
            
            withoutResultView.layer.insertSublayer(shadowLayer, at: 0)
            
        } else if takeQuizState == ButtonState.retakeQuiz {
            withResultView.isHidden = false
            withoutResultView.isHidden = true
            
            withResultQuizTitleLabel.text = quiz?.title
            
            myResultLabel.text = "My Result: \(currentUserResultType?.emoji ?? " ")"
            takeQuizButton.setTitle("  Retake Quiz", for: [])
            takeQuizButton.setImage(UIImage(systemName: "play.square.fill"), for: [])
            
            updateResultGroupButton(resultGroupButton: withResultResultGroupButton)
            //            withResultView.applyRoundedCornerAndShadow(viewType: .quizDetailBanner)
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: withResultView.bounds, cornerRadius: 18.0).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 2.5
            
            withResultView.layer.insertSublayer(shadowLayer, at: 0)
        }

        guessForTmatesButton.configuration?.subtitle = takenByText

        if takenByText == "Not taken by any t-mates yet" {
            guessForTmatesButton.isEnabled = false
        }
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
    }
    
    private func updateResultGroupButton(resultGroupButton: UIButton) {
        resultGroupButton.setTitle(quiz?.resultGroup.rawValue.capitalized, for: [])
        
        resultGroupButton.applyRoundedCornerAndShadow(borderType: .exploreTag)
        
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
                
                loadRetakeQuizRewardedAd()
                
                
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
    
    func fetchQuizHistory(completion: @escaping () -> Void) {
        guard let quizID = quiz?.id else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quizID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(withMessage: error.localizedDescription)
                completion()
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.quizHistory = try document.data(as: QuizHistory.self)
                        print("q \(self.quizHistory)")
                        
                        completion()
                    } catch {
                        self.presentErrorAlert(withMessage: error.localizedDescription)
                        completion()
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
                
                DispatchQueue.main.async {
                    self.takeQuizState = self.quizHistory.completedUsers.contains(userID) ? ButtonState.retakeQuiz : ButtonState.takeQuiz
                    self.updateUIText()
                    print("updating")
                }
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
