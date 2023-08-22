//
//  MemberQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GuessQuizViewController: UIViewController {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var quizQuestionLabel: UILabel!
    @IBOutlet var multiChoiceButton1: UIButton!
    @IBOutlet var multiChoiceButton2: UIButton!
    @IBOutlet var multiChoiceButton3: UIButton!
    @IBOutlet var multiChoiceButton4: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var multiChoiceButtons: [UIButton]!
    
    var fromResultVC: Bool?
    
    var quiz: Quiz?
    var group: Group?
    var userQuizHistory: UserQuizHistory?
    var members = [User]()
    var guessedMember: User?
    
    var guessedResultType: ResultType! // selected by user
    
    var resultChoices: [ResultType] = []
    var selectedButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
    }
    

    func updateUI() {
        for button in multiChoiceButtons {
            button.tintColor = UIColor(named: "primaryLightOrange")
            button.setTitleColor(UIColor(named: "darkOrangeText"), for: [])
            
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
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
        fetchUser {
            self.updateUser {
                self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
            }
        }
    }
    
    func updateUser(completion: @escaping () -> Void) {
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
    
    private func fetchUser(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(_):
                let points = self.guessedResultType == self.userQuizHistory?.finalResult ? Points.guessCorrect : Points.guessIncorrect
                
                docRef.updateData([
                    "points": FieldValue.increment(Int64(points))
                ])
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
}
