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
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        print("error")
    }
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        print("any")
                
        guard segue.identifier == "saveUnwind", let uid = Auth.auth().currentUser?.uid else { return }
        
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespaces)
        let bio = bioTextView.text.trimmingCharacters(in: .whitespaces)
        
        let profileInfoChanged = (username != user?.username || bio != user?.bio)
        
        if user != nil {
            user?.username = username
            user?.bio = bio
        } else {
            user = User(uid: uid ,username: username, bio: bio)
        }
        
        if profileInfoChanged {
            Helper.presentLoading(on: self, with: "Saving Profile Info")
            addUser(user: user!)
        }
    }
    
    func addUser(user: User) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let collectionRef = FirestoreService.shared.db.collection("users")
        
        do {
            try collectionRef.document(userId).setData(from: user)
            dismiss(animated: false, completion: nil)
        }
        catch {
            dismiss(animated: false, completion: nil)
            presentErrorAlert(with: error.localizedDescription)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Check username availability before saving
        
        if let username = usernameTextField.text {
            checkUsernameAvailability(username: username) { isAvailable in
                if isAvailable {
                    // Username is unique, perform the unwind segue
                    self.performSegue(withIdentifier: "saveUnwind", sender: sender)
                } else {
                    // Username is not unique, show error
                    self.presentErrorAlert(with: "Username is already taken.")
                }
            }
        }
    }
    
    func checkUsernameAvailability(username: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = FirestoreService.shared.db.collection("users")
        
        collectionRef.whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking username availability: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Username already exists
                completion(false)
            } else {
                // Username is available
                completion(true)
            }
        }
    }
}
