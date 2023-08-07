//
//  QuizDetailViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-05.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class QuizDetailViewController: UIViewController {
    var quiz: Quiz?
    var currentUser: User?
    var quizHistory: QuizHistory!
    var quizCompleteState: Bool = false
    var currentUserResultType: ResultType?
    var takenByText: String!
    
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var myResultLabel: UILabel!
    @IBOutlet var resultEmojiLabel: UILabel!
    @IBOutlet var resultDetailButton: UIButton!
    @IBOutlet var takeQuizButton: UIButton!
    @IBOutlet var guessForTmatesButton: UIButton!
    @IBOutlet var takeQuizPriceLabel: UILabel!
    @IBOutlet var guessForTmatesPriceLabel: UILabel!
    @IBOutlet var questionMarkLabel: UILabel!
    
    @IBOutlet var quizButtons: [UIButton]!
    
    var isRetakeQuiz: Bool?
    
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
        updateUIText()
    }
    
    private func updateUIText() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        takeQuizState = quizHistory.completedUsers.contains(userID) ? ButtonState.retakeQuiz : ButtonState.takeQuiz
        
        if takeQuizState == ButtonState.takeQuiz {
            myResultLabel.isHidden = true
            resultEmojiLabel.isHidden = true
            resultDetailButton.isHidden = true
            questionMarkLabel.isHidden = false
            
            takeQuizPriceLabel.text = "Free"
            takeQuizButton.setTitle("Take Quiz", for: [])
        } else if takeQuizState == ButtonState.retakeQuiz {
            myResultLabel.isHidden = false
            resultEmojiLabel.isHidden = false
            resultDetailButton.isHidden = false
            questionMarkLabel.isHidden = true
            
            resultEmojiLabel.text = "\(currentUserResultType?.emoji ?? " ")"
            takeQuizPriceLabel.text = "\(Price.retakeQuiz) 💸"
            takeQuizButton.setTitle("Retake Quiz", for: [])
        }
        
        quizTitleLabel.text = quiz?.title
        
        // If no t-mates have taken quiz
        if takenByText == TakenByText.noTmates {
            guessForTmatesButton.isUserInteractionEnabled = false
            
            guessForTmatesButton.tintColor = .systemGray2
            print("truee")
        } else {
            guessForTmatesButton.isEnabled = true
            guessForTmatesButton.tintColor = UIColor.systemCyan
            print("false")
        }
        guessForTmatesButton.configuration?.subtitle = takenByText
    }
    
    private func updateButtonFont() {
        for button in quizButtons {
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
                return outgoing
            }
        }
    }
    
    @IBAction func showQuiz(_ sender: UIButton) {
        isRetakeQuiz = takeQuizState == ButtonState.retakeQuiz
        if isRetakeQuiz! {
            
        } else {
            performSegue(withIdentifier: "showPersonalQuiz", sender: nil)
        }
    }
    
    func fetchQuizHistory() {
        guard let quizID = quiz?.id else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quizID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
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
                        self.presentErrorAlert(with: error.localizedDescription)
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
                self.currentUserResultType = user.quizHistory.first(where: { $0.quizID == self.quiz?.id })?.finalResult
                print("result type \(self.currentUserResultType)")
                self.updateUIText()
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showPersonalQuiz" {
            let personalQuizVC = segue.destination as! PersonalQuizViewController
            personalQuizVC.isRetakeQuiz = isRetakeQuiz
            personalQuizVC.currentUser = currentUser
            personalQuizVC.quiz = quiz
            
        }
    }
    
}
