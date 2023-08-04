//
//  EditProfileTableViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseAuth

class EditProfileTableViewController: UITableViewController {
    var user: User?

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            usernameTextField.text = user.username
            bioTextView.text = user.bio
        }
        
        updateSaveButtonState()
    }
    
    // Enable save button only when the username text field is not empty
    func updateSaveButtonState() {
        let shouldEnableSaveButton = usernameTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
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
                
        guard segue.identifier == "saveUnwind", let uid = Auth.auth().currentUser?.uid else { return }
        
        let username = usernameTextField.text!
        let bio = bioTextView.text
        
        if user != nil {
            user?.username = username
            user?.bio = bio
        } else {
            user = User(uid: uid ,username: username, bio: bio)
        }
        
        let userQuizHistory = UserQuizHistory(quizID: QuizData.quizzes[0].id, userCompleteTime: Date(), finalResult: .apple, chosenAnswers: [:])
        // Create a UserQuizHistory instance and use the quizID
        let userQuizHistory2 = UserQuizHistory(quizID: QuizData.quizzes[1].id, userCompleteTime: Date(), finalResult: .car, chosenAnswers: [:])

        self.user = User(uid: uid, username: "s", bio: "s", quizHistory: [userQuizHistory, userQuizHistory2])
        
        addUser(user: user!)
    }
    
    func addUser(user: User) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let collectionRef = FirestoreService.shared.db.collection("users")
        
        do {
            // Create a UserQuizHistory instance and use the quizID
            
            
            try collectionRef.document(userId).setData(from: user)
        }
        catch {
            presentErrorAlert(with: error.localizedDescription)
        }
    }
    
}
