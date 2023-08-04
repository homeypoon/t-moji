//
//  MemberQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit

class MemberQuizViewController: UIViewController {
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
    var members = [User]()
    var member: User?
    var quizHistory: UserQuizHistory?
    
    var resultChoices: [ResultType] = []
    var selectedButton: UIButton?

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

        if let quizHistory = quizHistory,
           let member = member {
            
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
        
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let selectedResultType: ResultType
        
        switch selectedButton {
        case multiChoiceButton1:
            selectedResultType = resultChoices[0]
        case multiChoiceButton2:
            selectedResultType = resultChoices[1]
        case multiChoiceButton3:
            selectedResultType = resultChoices[2]
        case multiChoiceButton4:
            selectedResultType = resultChoices[3]
        default:
            break
        }
    }
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "submitMemberQuiz" else { return }
        
        let quizResultVC = segue.destination as! QuizResultCollectionViewController
        quizResultVC.group = self.group
        quizResultVC.quiz = self.quiz
        quizResultVC.members = self.members
        quizResultVC.currentMember = self.member
        quizResultVC.quizHistory = self.quizHistory
    }
}
