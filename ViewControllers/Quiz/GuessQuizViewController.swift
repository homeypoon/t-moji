//
//  GuessQuizViewController.swift
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
        
        print("no thanks clicked")
        removeBlurEffect()
        updateUserWithPointsAndGuessCount {
            
            self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
        }
    }
    
    func extraGuessGranted() {
        showExtraGuessRewardAd()
        removeBlurEffect()
    }
    
    @IBOutlet var bannerView: GADBannerView!
    
    @IBOutlet var quizQuestionTextView: UITextView!
    
    @IBOutlet var multiChoiceButton1: UIButton!
    @IBOutlet var multiChoiceButton2: UIButton!
    @IBOutlet var multiChoiceButton3: UIButton!
    @IBOutlet var multiChoiceButton4: UIButton!
    @IBOutlet var multiChoiceStackView: UIStackView!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var rangedStackView: UIStackView!
    
    @IBOutlet var rangedSlider: UISlider!
    @IBOutlet var rangedLabel1: UILabel!
    @IBOutlet var rangedLabel2: UILabel!
    
    @IBOutlet var multiChoiceButtons: [UIButton]!
    @IBOutlet var quizProgressView: UIProgressView!
    
    var questionIndex: Int = 0
    var currentQuestion: Question!
    var possibleAnswers: [Answer]!
    
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    var fromResultVC: Bool? = false
    
    var quiz: Quiz?
    var group: Group?
    var userQuizHistory: UserQuizHistory?
    
    typealias QuestionIndex = Int
    var chosenAnswers: [QuestionIndex: Answer] = [:]
    
    var members = [User]()
    var guessedMember: User?
    
    var guessedResultType: ResultType! // selected by user
    
    var totalGuesses: Int = 0
    var correctGuesses: Int = 0
    var isCorrect: Bool = false
    
    var submitButtonClickRequired: Bool = false
    
    var previousWrongSelectedButton: UIButton?
    
    var resultChoices: [ResultType] = []
    var selectedButton: UIButton?
    
    var blurEffectView: UIVisualEffectView?
    @IBOutlet var extraGuessPopupView: ExtraGuessPopupView!
    var loadingSpinner: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        extraGuessPopupView.removeFromSuperview()
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quiz = QuizData.quizzes.first(where: { $0.id == userQuizHistory?.quizID })
        
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner?.center = view.center
        loadingSpinner?.hidesWhenStopped = true
        
        extraGuessPopupView.delegate = self
        
        bannerView.adUnitID = "c∂a-app-pub-2315105541829350/5389008147"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        updateInitialUI()
        updateUiForGuessAnswers()
        
        totalGuesses = quiz?.questions.count ?? 0
        
        quizQuestionTextView.applyStyle(textViewType: .quizQuestion)
        
        loadGuessRewardedAd()
        
    }
    
    private func loadGuessRewardedAd() {
        
        GADRewardedInterstitialAd.load(withAdUnitID:"ca-app-pub-2315105541829350/1590356210",
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
            //          loadGuessRewardedAd()
            self.updateUiForTmojiAnswer()
            return
        }
        rewardedInterstitialAd.present(fromRootViewController: self) {
            self.updateUiForTmojiAnswer()
            self.loadGuessRewardedAd()
        }
    }
    
    func updateInitialUI() {
        for button in multiChoiceButtons {
            if button == previousWrongSelectedButton {
                button.isEnabled = false
                
                button.tintColor = UIColor(named: "guessedButtonColor")
                button.layer.borderColor = UIColor(named: "guessedButtonColor")?.withAlphaComponent(0.4).cgColor
                button.applyRoundedCornerAndShadow(borderType: .guessButton)
            } else {
                
                button.tintColor = UIColor(named: "primaryLightOrange")
                button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
                
                button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont.systemFont(ofSize: 24, weight: .medium)
                    return outgoing
                }
                
                button.applyRoundedCornerAndShadow(borderType: .guessButton)
                
                button.titleLabel?.textAlignment = .center
            }
        }
        
        submitButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            return outgoing
        }
        
        submitButton.tintColor = UIColor(named: "primaryRed")
        submitButton.setTitleColor(UIColor(named: "white"), for: [])
        
        submitButton.applyRoundedCornerAndShadow(borderType: .guessSubmitButton)
    }
    
    func updateUiForTmojiAnswer() {
        guard let quiz = quiz else {return }
        navigationItem.title = "T-Moji Guess - \(questionIndex + 1)/\(quiz.questions.count + 1)"
        // changed to + 1 for quiz.questions.count
        let totalProgress = Float(questionIndex) / Float(quiz.questions.count + 1)
        quizProgressView.setProgress(totalProgress, animated: true)
        
        if let quizHistory = userQuizHistory,
           let member = guessedMember {
            
            if let quiz = QuizData.quizzes.first(where: { $0.id == quizHistory.quizID }) {
                self.quiz = quiz
                
                quizQuestionTextView.text = "Which \(quiz.resultGroup.rawValue) do you think \(member.username) got?"
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
    
    func trimUsername(username: String, maxChars: Int) -> String {
        if username.count > maxChars {
            let trimmedUsername = String(username.prefix(maxChars)) + "..."
            return trimmedUsername
        } else {
            return username
        }
    }
    
    func updateUiForGuessAnswers() {
        print("quizfsjkjfslj \(String(describing: quiz))")
        guard let quiz = quiz else { return }
        currentQuestion = quiz.questions[questionIndex]
        possibleAnswers = currentQuestion.possibleAnswers
        
        quizQuestionTextView.text = currentQuestion.text
        
        multiChoiceStackView.isHidden = true
        rangedStackView.isHidden = true
        
        if let guessedMemberUsername = guessedMember?.username {
            navigationItem.title = "\(trimUsername(username: guessedMemberUsername, maxChars: 18))'s POV - \(questionIndex + 1)/\(quiz.questions.count + 1)"
        }
        
        // changed to + 1 for quiz.questions.count
        let totalProgress = Float(questionIndex) / Float(quiz.questions.count + 1)
        quizProgressView.setProgress(totalProgress, animated: true)
        
        switch currentQuestion.type {
        case .multipleChoice:
            updateMultiChoiceStack(using: possibleAnswers)
        case .ranged:
            updateRangeStack(using: possibleAnswers)
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
        submitButtonClickRequired = !submitButtonClickRequired
        
        print("in")
        guard let quiz = quiz else { return }
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
            button.layer.shadowColor = UIColor(named: "primaryDarkOrange")?.cgColor
            button.isUserInteractionEnabled = true
        }
        
        if questionIndex == quiz.questions.count {
            print("yes")
            
            guessedTmojiAnswer()
//            ***********
        } else {
            if submitButtonClickRequired {
                for button in multiChoiceButtons {
                    button.isUserInteractionEnabled = false
                    rangedSlider.isUserInteractionEnabled = false
                }
                submitButton.setTitle("Next Question", for: [])
                submitButton.tintColor = UIColor(named: "primaryDarkOrange")
            } else {
                for button in multiChoiceButtons {
                    button.isUserInteractionEnabled = true
                    rangedSlider.isUserInteractionEnabled = true
                }
                submitButton.setTitle("Submit", for: [])
                submitButton.tintColor = UIColor(named: "primaryRed")
            }
            
            switch currentQuestion.type {
            case .multipleChoice:
                if !submitButtonClickRequired {
                    nextQuestion()
                } else {
                    showCorrectMultiAnswer()
                }
                
            case .ranged:
                if !submitButtonClickRequired {
                    nextQuestion()
                    //                updateRangedSelectedAnswer()
                } else {
                    showCorrectRangedAnswer()
                }
            }
        }
    }
    
    func guessedTmojiAnswer() {
        guard selectedButton != nil else { return }
        
        submitButton.isUserInteractionEnabled = false
        if let loadingSpinner = loadingSpinner {
            view.addSubview(loadingSpinner)
            
            loadingSpinner.startAnimating()
        }
        
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
            loadingSpinner?.stopAnimating()
            self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
            
        } else {
            // If user is correct, perform segue
            if guessedResultType == userQuizHistory?.finalResult {
                isCorrect = true
                updateUserWithPointsAndGuessCount {
                    self.updateGuessedMembers {
                        self.loadingSpinner?.stopAnimating()
                        self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
                    }
                }
            } else {
                isCorrect = false
                // Show extra guess pop up
                self.navigationItem.hidesBackButton = true
                
                previousWrongSelectedButton = selectedButton
                loadingSpinner?.stopAnimating()
                
                showExtraGuessPopup()
                
                extraGuessPopupView.restartCountdown()
                
                self.updateGuessedMembers { }
                
                selectedButton = nil
                submitButton.isUserInteractionEnabled = true
                
            }
            
        }
    }
    
    func showCorrectMultiAnswer() {
        print("entored")
        
        guard let selectedButton = selectedButton else { return }
        
        switch selectedButton {
        case multiChoiceButton1:
            chosenAnswers[questionIndex] = possibleAnswers[0]
        case multiChoiceButton2:
            chosenAnswers[questionIndex] = possibleAnswers[1]
        case multiChoiceButton3:
            chosenAnswers[questionIndex] = possibleAnswers[2]
        case multiChoiceButton4:
            chosenAnswers[questionIndex] = possibleAnswers[3]
        default:
            break
        }
        
        guard let userGuessAnswer = chosenAnswers[questionIndex] else { return }
        guard let correctGuessAnswer: Answer = userQuizHistory?.chosenAnswers[questionIndex]?.first as? Answer else { return }
        
        if userGuessAnswer.text == correctGuessAnswer.text {
            updateButtonsForCorrectMulti(correctText: correctGuessAnswer.text, chosenButton: selectedButton, userCorrect: true)
        } else {
            updateButtonsForCorrectMulti(correctText: correctGuessAnswer.text, chosenButton: selectedButton, userCorrect: false)
        }
    }
    
    func updateButtonsForCorrectMulti(correctText: String, chosenButton: UIButton, userCorrect: Bool) {
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
        }
        // Set the correct button's color
        if userCorrect {
            correctGuesses += 1
            chosenButton.tintColor = UIColor(named: "correctGreen")
            chosenButton.setTitleColor(UIColor(named: "white"), for: [])
            chosenButton.layer.shadowColor = UIColor(named: "correctGreen")?.cgColor
        } else {
            chosenButton.tintColor = UIColor(named: "wrongRed")
            chosenButton.setTitleColor(UIColor(named: "white"), for: [])
            chosenButton.layer.shadowColor = UIColor(named: "wrongRed")?.cgColor
            
            // set wrong button
            if possibleAnswers[0].text == correctText {
                multiChoiceButton1.tintColor = UIColor(named: "correctGreen")
                multiChoiceButton1.setTitleColor(UIColor(named: "white"), for: [])
                multiChoiceButton1.layer.shadowColor = UIColor(named: "correctGreen")?.cgColor
            } else if possibleAnswers[1].text == correctText {
                multiChoiceButton2.tintColor = UIColor(named: "correctGreen")
                multiChoiceButton2.setTitleColor(UIColor(named: "white"), for: [])
                multiChoiceButton2.layer.shadowColor = UIColor(named: "correctGreen")?.cgColor
            } else if possibleAnswers[2].text == correctText {
                multiChoiceButton3.tintColor = UIColor(named: "correctGreen")
                multiChoiceButton3.setTitleColor(UIColor(named: "white"), for: [])
                multiChoiceButton3.layer.shadowColor = UIColor(named: "correctGreen")?.cgColor
            } else if possibleAnswers[3].text == correctText {
                multiChoiceButton4.tintColor = UIColor(named: "correctGreen")
                multiChoiceButton4.setTitleColor(UIColor(named: "white"), for: [])
                multiChoiceButton4.layer.shadowColor = UIColor(named: "correctGreen")?.cgColor
            }
        }
    }
    
    func showCorrectRangedAnswer() {
        let index = Int(round(rangedSlider.value * Float(possibleAnswers.count - 1)))
        
        chosenAnswers[questionIndex] = possibleAnswers[index]
        
//        print("questionIndex \(questionIndex)")
//        print("chosenAnswerssssss \(chosenAnswers)")
//        print("userQuizHistory?.chosenAnswers \(userQuizHistory?.chosenAnswers)")
        
        guard let userGuessAnswer = chosenAnswers[questionIndex] else { return }
        guard let correctGuessAnswer: Answer = userQuizHistory?.chosenAnswers[questionIndex]?.first as? Answer else { return }
                
        if userGuessAnswer.text == correctGuessAnswer.text {
            correctGuesses += 1
            rangedSlider.minimumTrackTintColor = UIColor(named: "correctGreen")
        } else {
            rangedSlider.minimumTrackTintColor = UIColor(named: "wrongRed")
        }
        print(correctGuessAnswer.rangedValue)
        guard let rangedValue = correctGuessAnswer.rangedValue else { return }
        
        self.rangedSlider.setValue(rangedValue, animated: true)
    }
    
    func updateRangedSelectedAnswer() {
        
        let index = Int(round(rangedSlider.value * Float(possibleAnswers.count - 1)))
        
        chosenAnswers[questionIndex] = possibleAnswers[index]
        
        nextQuestion()
    }
    
    func nextQuestion() {
        questionIndex += 1
        
        guard let quiz = quiz else { return }
        
        if questionIndex < quiz.questions.count {
            updateUiForGuessAnswers()
        } else {
            updateUiForTmojiAnswer()
        }
    }
    
    func updateMultiChoiceStack(using answers: [Answer]) {
        print(true)
        multiChoiceStackView.isHidden = false
        
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
            button.layer.shadowColor = UIColor(named: "primaryDarkOrange")?.cgColor
        }
        selectedButton = nil
        
        rangedSlider.setValue(0.5, animated: false)
        multiChoiceButton1.setTitle(answers[0].text, for: [])
        multiChoiceButton2.setTitle(answers[1].text, for: [])
        multiChoiceButton3.setTitle(answers[2].text, for: [])
        multiChoiceButton4.setTitle(answers[3].text, for: [])
    }
    
    func updateRangeStack(using answers: [Answer]) {
        rangedSlider.minimumTrackTintColor = UIColor(named: "primaryDarkOrange")
        rangedStackView.isHidden = false
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
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
                
                let points = Points.calculatePoints(totalGuesses: self.totalGuesses, correctGuesses: self.correctGuesses, isCorrect: self.isCorrect)
                
                if let quiz = self.quiz {
                    let wrongGuesses = quiz.questions.count - self.correctGuesses
                    
                    if self.guessedResultType == self.userQuizHistory?.finalResult {
                        docRef.updateData([
                            "points": FieldValue.increment(Int64(points)),
                            "correctGuesses": FieldValue.increment(Int64((self.correctGuesses + 1))),
                            "wrongGuesses": FieldValue.increment(Int64(wrongGuesses))
                        ])
                    } else {
                        docRef.updateData([
                            "points": FieldValue.increment(Int64(self.correctGuesses)),
                            "wrongGuesses": FieldValue.increment(Int64(wrongGuesses + 1))
                        ])
                    }
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
        guessResultVC.correctGuesses = self.correctGuesses
        guessResultVC.totalGuesses = self.totalGuesses
        
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func showExtraGuessPopup() {
        addBlurEffect()
        view.addSubview(extraGuessPopupView)
        extraGuessPopupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            extraGuessPopupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            extraGuessPopupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            extraGuessPopupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            extraGuessPopupView.heightAnchor.constraint(equalToConstant: 330)
        ])
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
        presentErrorAlert(with: "The video wasn't available, but you still get another guess!")
        updateUiForTmojiAnswer()
    }
    
    /// ad dismissed
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //        self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
    }
}
