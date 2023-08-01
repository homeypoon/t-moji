//
//  AddGroupMembersViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class AddGroupMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PotentialGroupMemberCellDelegate {
    func addToGroupButtonTapped(sender: PotentialGroupMemberTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var user = users[indexPath.row]
            user.isSelected.toggle()
            users[indexPath.row] = user
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateSaveButtonState()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createGroupButton: UIBarButtonItem!
    @IBOutlet var groupNameTextField: UITextField!
    
    var users = [User]()
    
    var group: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        fetchUsers()
        
        updateSaveButtonState()
    }
    
    // Enable save button when group name is not empty and at least one member is selected
    func updateSaveButtonState() {
        let shouldEnableSaveButton = groupNameTextField.text?.isEmpty == false && users.contains { $0.isSelected }
        createGroupButton.isEnabled = shouldEnableSaveButton
    }
    
    @IBAction func textEditingChanged(_ sender: Any) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func createGroupButtonPressed(_ sender: UIButton) {
        updateSaveButtonState()
        if createGroupButton.isEnabled {

        }
    }
    
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "showGroupHome" else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let groupName = groupNameTextField.text!
        var membersIDs = users
            .filter { $0.isSelected }
            .compactMap { $0.uid }
        
        membersIDs.append(userID)
        
        group = Group(name: groupName, leader: userID, membersIDs: membersIDs)
        addGroup(group: group!)

        let groupHomeVC = segue.destination as! GroupHomeCollectionViewController
        groupHomeVC.group = group
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PotentialGroupMember", for: indexPath) as! PotentialGroupMemberTableViewCell
        
        cell.delegate = self
        
        let user = users[indexPath.row]
        cell.usernameLabel?.text = user.username

        cell.addToGroupButton.isSelected = user.isSelected
        
        return cell
    }
    
    // Get all users in the app (temporary - later filter for only friended users)
    private func fetchUsers() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirestoreService.shared.db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        
                        var user = try document.data(as: User.self)
                        
                        if user.uid != uid {
                            user.isSelected = false
                            self.users.append(user)
                        }
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func addGroup(group: Group) {
        let collectionRef = FirestoreService.shared.db.collection("groups")
        
        do {
            try collectionRef.addDocument(from: group)
        }
        catch {
            print(error)
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
