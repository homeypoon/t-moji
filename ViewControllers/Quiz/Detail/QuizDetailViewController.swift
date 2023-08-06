//
//  QuizDetailViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-05.
//

import UIKit

class QuizDetailViewController: UIViewController {
    var quiz: Quiz?
    var currentUser: User?
    var quizHistory: QuizHistory?
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeQuizState = currentUserResultType == nil ? ButtonState.takeQuiz : ButtonState.retakeQuiz
        
        updateButtonFont()
        updateUIText()
        
    }
    
    private func updateUIText() {
        if takeQuizState == ButtonState.takeQuiz {
            myResultLabel.isHidden = true
            resultEmojiLabel.isHidden = true
            resultDetailButton.isHidden = true
            questionMarkLabel.isHidden = false
            
            resultEmojiLabel.text = "\(currentUserResultType?.emoji ?? " ")"
            takeQuizPriceLabel.text = "Free"
            takeQuizButton.setTitle("Take Quiz", for: [])
        } else if takeQuizState == ButtonState.retakeQuiz {
            myResultLabel.isHidden = false
            resultEmojiLabel.isHidden = false
            resultDetailButton.isHidden = false
            questionMarkLabel.isHidden = true
            
            takeQuizPriceLabel.text = "\(Price.retakeQuiz) 💸"
            takeQuizButton.setTitle("Retake Quiz", for: [])
        }
        
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
