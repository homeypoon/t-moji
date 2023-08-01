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
    }
    
}
