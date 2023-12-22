//
//  PersonalQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-06.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import GoogleMobileAds

class PersonalQuizViewController: UIViewController {
    var isRetakeQuiz: Bool!
    var quiz: Quiz!
    var currentUser: User?
    var quizHistory: QuizHistory?
    
    var userQuizHistory: UserQuizHistory!
    
    typealias QuestionIndex = Int
    var chosenAnswers: [QuestionIndex: [Answer]] = [:]
    
    var selectedButton: UIButton?
    @IBOutlet var bannerView: GADBannerView!
    
    @IBOutlet var quizQuestionTextView: UITextView!
    
    @IBOutlet var multiChoiceStackView: UIStackView!
    @IBOutlet var multiChoiceButton1: UIButton!
    @IBOutlet var multiChoiceButton2: UIButton!
    @IBOutlet var multiChoiceButton3: UIButton!
    @IBOutlet var multiChoiceButton4: UIButton!
    @IBOutlet var multiChoiceButtons: [UIButton]!
    
    @IBOutlet var rangedStackView: UIStackView!
    @IBOutlet var rangedSlider: UISlider!
    @IBOutlet var rangedLabel1: UILabel!
    @IBOutlet var rangedLabel2: UILabel!
    
    @IBOutlet var quizProgressView: UIProgressView!
    
    @IBOutlet var submitButton: UIButton!
    var loadingSpinner: UIActivityIndicatorView?
    
    var questionIndex: Int = 0
    var currentQuestion: Question!
    var possibleAnswers: [Answer]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
//        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.adUnitID = "ca-app-pub-2315105541829350/5312986520"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        updateInitialUI()
        updateUI()

        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner?.center = view.center
        loadingSpinner?.hidesWhenStopped = true
    }
    
    func updateInitialUI() {
        for button in multiChoiceButtons {
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 24, weight: .medium)
                return outgoing
            }
            button.applyRoundedCornerAndShadow(borderType: .quizButton)
            
            button.titleLabel?.textAlignment = .center
            
            quizQuestionTextView.applyStyle(textViewType: .quizQuestion)
        }
        
        submitButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            return outgoing
        }
        
        submitButton.applyRoundedCornerAndShadow(borderType: .quizSubmitButton)
    }
    
    func updateUI() {
        
        currentQuestion = quiz.questions[questionIndex]
        possibleAnswers = currentQuestion.possibleAnswers
        
        quizQuestionTextView.text = currentQuestion.text
        
        let totalProgress = Float(questionIndex) / Float(quiz.questions.count)
        
        multiChoiceStackView.isHidden = true
        rangedStackView.isHidden = true
        
        navigationItem.title = "Question \(questionIndex + 1)/\(quiz.questions.count)"
        quizProgressView.setProgress(totalProgress, animated: true)
        
        if questionIndex == (quiz.questions.count - 1) {
//            if isRetakeQuiz {
//                submitButton.setTitle("Submit Quiz -\(Price.retakeQuiz)💸", for: [])
//            } else {
            submitButton.setTitle("Submit Quiz", for: [])
//            }
        }
        
        switch currentQuestion.type {
        case .multipleChoice:
            updateMultiChoiceStack(using: possibleAnswers)
        case .ranged:
            updateRangeStack(using: possibleAnswers)
        }
    }
    
    func updateMultiChoiceStack(using answers: [Answer]) {
        print(true)
        multiChoiceStackView.isHidden = false
        
        
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightRed")
            button.setTitleColor(UIColor(named: "darkRedText"), for: [])
        }
        selectedButton = nil
        
        rangedSlider.setValue(0.5, animated: false)
        multiChoiceButton1.setTitle(answers[0].text, for: [])
        multiChoiceButton2.setTitle(answers[1].text, for: [])
        multiChoiceButton3.setTitle(answers[2].text, for: [])
        multiChoiceButton4.setTitle(answers[3].text, for: [])
    }
    
    func updateRangeStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
    }
    
    @IBAction func multiChoiceButtonTapped(_ sender: UIButton) {
        // Reset the color of all buttons
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightRed")
            button.setTitleColor(UIColor(named: "darkRedText"), for: [])
        }
        
        // Set the selected button's color
        sender.tintColor = UIColor(named: "primaryRed")
        
        sender.setTitleColor(UIColor(named: "white"), for: [])
        
        selectedButton = sender
    }
    
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        switch currentQuestion.type {
        case .multipleChoice:
            updateMultiChoiceSelectedAnswer()
        case .ranged:
            updateRangedSelectedAnswer()
        }
    }
    
    func updateMultiChoiceSelectedAnswer() {
        
        if selectedButton != nil {
            switch selectedButton {
            case multiChoiceButton1:
                chosenAnswers[questionIndex] = [possibleAnswers[0]]
            case multiChoiceButton2:
                chosenAnswers[questionIndex] = [possibleAnswers[1]]
            case multiChoiceButton3:
                chosenAnswers[questionIndex] = [possibleAnswers[2]]
            case multiChoiceButton4:
                chosenAnswers[questionIndex] = [possibleAnswers[3]]
            default:
                break
            }
            
            nextQuestion()
        }
    }
    
    func updateRangedSelectedAnswer() {
        
        let index = Int(round(rangedSlider.value * Float(possibleAnswers.count - 1)))
        
        chosenAnswers[questionIndex] = [possibleAnswers[index]]
        
        nextQuestion()
    }
    
    func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < quiz.questions.count {
            updateUI()
        } else {
            submitQuiz()
        }
    }
    
    func submitQuiz() {
        if let loadingSpinner = loadingSpinner {
            view.addSubview(loadingSpinner)
            
            loadingSpinner.startAnimating()
        }
        
        let dispatchGroup = DispatchGroup()
        self.userQuizHistory = UserQuizHistory(quizID: quiz.id, userCompleteTime: Date(), finalResult: quiz.calculateResult(chosenAnswers: chosenAnswers), chosenAnswers: chosenAnswers)
        
        if var currentUser = currentUser {
            if let index = currentUser.userQuizHistory.firstIndex(where: { $0.quizID == self.userQuizHistory.quizID }) {
                // If it's a retake, replace the item at the found index with the new self.userQuizHistory
                if isRetakeQuiz {
                    currentUser.userQuizHistory[index] = self.userQuizHistory
                }
            } else {
                // If it's not a retake, append the new userQuizHistory
                currentUser.userQuizHistory.append(self.userQuizHistory)
            }
            // Update the modified 'currentUser' back to the original 'currentUser' object
            self.currentUser = currentUser
        }
        
        func presentErrorAlert(with message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        submitButton.isUserInteractionEnabled = false
        
        dispatchGroup.enter()
        addQuizHistory {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        updateUser {
            dispatchGroup.leave()
        }
        
        
        dispatchGroup.notify(queue: .main) {
            self.loadingSpinner?.stopAnimating()
            self.submitButton.isUserInteractionEnabled = true
           
            self.performSegue(withIdentifier: "showPersonalResults", sender: nil)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "showPersonalResults" else { return }
        
        let navController = segue.destination as! UINavigationController
        let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
        
//        let quizResultVC = segue.destination as! QuizResultCollectionViewController
        quizResultVC.quiz = self.quiz
        quizResultVC.resultUser = self.currentUser
        quizResultVC.userQuizHistory = self.userQuizHistory
        quizResultVC.quizResultType = isRetakeQuiz ? .ownRetake : .ownQuiz
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func addQuizHistory(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quiz.id).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        var quizHistory = try document.data(as: QuizHistory.self)
                        quizHistory.completedUsers.append(userID)
                        self.quizHistory = quizHistory
                        
                            document.reference.updateData([
                                "completedUsers": FieldValue.arrayUnion([userID]),
                            ])
                    
                    } catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                completion()
            }
        }
    }
    
    
    func updateUser(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let collectionRef = FirestoreService.shared.db.collection("users")
        
        do {
            var points = 0
            if !isRetakeQuiz {
                self.currentUser?.points += Points.takeQuiz
                
            } else {
                self.currentUser?.points += Points.retakeQuiz
            }
            
            try collectionRef.document(userId).setData(from: self.currentUser)
            
            completion()
        }
        catch {
            presentErrorAlert(with: error.localizedDescription)
            completion()
        }
    }
    
    // Used for adding quizzes
    func resetQuizHistories() {
        
        let collectionRef = FirestoreService.shared.db.collection("quizHistories")
        
        do {
            for quiz in QuizData.quizzes {
                let quizHistory = QuizHistory(quizID: quiz.id, completedUsers: [])
                try collectionRef.document(String(quiz.id)).setData(from: quizHistory)
            }
        }
        catch {
            presentErrorAlert(with: error.localizedDescription)
        }
    }
    
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}
