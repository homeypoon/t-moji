//
//  PersonalQuizViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-06.
//

import UIKit

class PersonalQuizViewController: UIViewController {
    var isRetakeQuiz: Bool!
    var quiz: Quiz!
    var currentUser: User?
    
    typealias QuestionIndex = Int
    var chosenAnswers: [QuestionIndex: [Answer]] = [:]
    
    var selectedButton: UIButton?
    
    @IBOutlet var quizQuestionLabel: UILabel!
    
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
    
    
    var questionIndex: Int = 0
    var currentQuestion: Question!
    var possibleAnswers: [Answer]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInitialUI()
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    func updateInitialUI() {
        for button in multiChoiceButtons {
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                return outgoing
            }
        }
        
        submitButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            return outgoing
        }
        
    }
    
    func updateUI() {
        
        currentQuestion = quiz.questions[questionIndex]
        possibleAnswers = currentQuestion.possibleAnswers
        
        quizQuestionLabel.text = currentQuestion.text
        
        let totalProgress = Float(questionIndex) / Float(quiz.questions.count)
        
        multiChoiceStackView.isHidden = true
        rangedStackView.isHidden = true
        
        navigationItem.title = "Question \(questionIndex + 1)/\(quiz.questions.count)"
        quizProgressView.setProgress(totalProgress, animated: true)
        
        if questionIndex == (quiz.questions.count - 1) {
            if isRetakeQuiz {
                submitButton.setTitle("Submit Quiz -\(Price.retakeQuiz)💸", for: [])
            } else {
                submitButton.setTitle("Submit Quiz", for: [])
            }
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
            button.tintColor = .systemTeal
        }
        selectedButton = nil
        
        rangedSlider.setValue(0.5, animated: false)
        multiChoiceButton1.setTitle(answers[0].text, for: .normal)
        multiChoiceButton2.setTitle(answers[1].text, for: .normal)
        multiChoiceButton3.setTitle(answers[2].text, for: .normal)
        multiChoiceButton4.setTitle(answers[3].text, for: .normal)
    }
    
    func updateRangeStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
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

        performSegue(withIdentifier: "showPersonalResults", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "showPersonalResults" else { return }
        
        let navController = segue.destination as! UINavigationController
        let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
        quizResultVC.quiz = self.quiz
        quizResultVC.quizKind = .personal
        quizResultVC.currentUser = self.currentUser
        
        quizResultVC.quizHistory = UserQuizHistory(quizID: quiz.id, userCompleteTime: Date(), finalResult: quiz.calculateResult(chosenAnswers: chosenAnswers), chosenAnswers: chosenAnswers)
        
        self.navigationController?.popViewController(animated: false)
    }
    
}
