//
//  MemberQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class GuessQuizViewController: UIViewController {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var quizQuestionLabel: UILabel!
    @IBOutlet var multiChoiceButton1: UIButton!
    @IBOutlet var multiChoiceButton2: UIButton!
    @IBOutlet var multiChoiceButton3: UIButton!
    @IBOutlet var multiChoiceButton4: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var multiChoiceButtons: [UIButton]!
    
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

        // Do any additional setup after loading the view.
    }
    

    func updateUI() {
        for button in multiChoiceButtons {
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                return outgoing
            }
        }

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
            button.tintColor = .systemTeal
        }
        
        // Set the selected button's color
        sender.tintColor = .systemBlue
        
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
        updateUser {
            self.performSegue(withIdentifier: "submitMemberQuiz", sender: nil)
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
    
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "submitMemberQuiz" else { return }
        
        let navController = segue.destination as! GuessResultCollectionViewController
        
        navController.group = self.group
        navController.quiz = self.quiz
        navController.members = self.members
        navController.guessedUser = self.guessedMember
        navController.userQuizHistory = self.userQuizHistory
        navController.guessedResultType = self.guessedResultType
        
        self.navigationController?.popViewController(animated: true)
    }
}
