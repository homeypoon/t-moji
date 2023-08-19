//
//  AddGroupMembersViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddGroupMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PotentialGroupMemberCellDelegate {
    func addToGroupButtonTapped(sender: PotentialGroupMemberTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let user = users[indexPath.row]
            userSelectedState[user.uid] = !(userSelectedState[user.uid] ?? false) // Toggle selected state
            tableView.reloadData()
            updateSaveButtonState()
        }
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createGroupButton: UIBarButtonItem!
    @IBOutlet var groupNameTextField: UITextField!
    
    var users = [User]()
    private var allUsers = [User]()
    
    private var selectedUsers = [User]()
    var unselectedUsers = [User]()
    
    private var userSelectedState: [String: Bool] = [:]
    
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
        let shouldEnableSaveButton = groupNameTextField.text?.isEmpty == false && users.contains { userSelectedState[$0.uid] ?? false }
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Sort users array based on selected state
        users.sort { (user1, user2) in
            let isSelected1 = userSelectedState[user1.uid] ?? false
            let isSelected2 = userSelectedState[user2.uid] ?? false
            return isSelected1 && !isSelected2
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PotentialGroupMember", for: indexPath) as! PotentialGroupMemberTableViewCell
        
        cell.delegate = self
        
        let user = users[indexPath.row]
        cell.usernameLabel?.text = user.username
        cell.addToGroupButton.isSelected = userSelectedState[user.uid] ?? false // Use dictionary value
        
        return cell
    }
    
    
    // Get all users in the app (temporary - later filter for only friended users)
    private func fetchUsers() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.users.removeAll()
        self.allUsers.removeAll()
        
        FirestoreService.shared.db.collection("users").whereField(FieldPath.documentID(), isNotEqualTo: uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        var user = try document.data(as: User.self)
                        self.userSelectedState[user.uid] = false
                        self.users.append(user)
                        self.allUsers.append(user)
                        
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    func addGroup(group: Group) -> String? {
        let collectionRef = FirestoreService.shared.db.collection("groups")
        
        do {
            let docRef = try collectionRef.addDocument(from: group)
            
            FirestoreService.shared.db.collection("users").whereField("uid", in: group.membersIDs).getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.presentErrorAlert(with: error.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            var currentMember = try document.data(as: User.self)
                            
                            
                            currentMember.masterGroupmatesIDs.append(contentsOf: group.membersIDs.filter { $0 != currentMember.uid })
                            
                            print("member ids \(currentMember.masterGroupmatesIDs)")
                            
                            document.reference.updateData([
                                "groupsIDs": FieldValue.arrayUnion([docRef.documentID]),
                                "masterGroupmatesIDs": currentMember.masterGroupmatesIDs
                            ])
                        } catch {
                            self.presentErrorAlert(with: error.localizedDescription)
                        }
                    }
                    
                }
            }
            return docRef.documentID
        }
        catch {
            presentErrorAlert(with: error.localizedDescription)
        }
        
        return nil
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
        
        guard segue.identifier == "showGroupHome" else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let groupName = groupNameTextField.text!
        var membersIDs = userSelectedState
            .filter { $0.value }
            .map { $0.key }
        
        membersIDs.append(userID)
        
        self.group = Group(name: groupName, leader: userID, membersIDs: membersIDs)
        let groupId = self.addGroup(group: self.group!)
        self.group?.id = groupId
        
        let groupHomeVC = segue.destination as! GroupHomeCollectionViewController
        groupHomeVC.group = self.group
    }
}

extension AddGroupMembersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            users = allUsers // Restore the original list when search text is empty
        } else {
            selectedUsers = users.filter { userSelectedState[$0.uid] ?? false }
            
            let filteredUsers = allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
            
            users = selectedUsers + filteredUsers.filter { !selectedUsers.contains($0) }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        selectedUsers = users.filter { userSelectedState[$0.uid] ?? false }
        
        users = allUsers // Restore the original list when search is canceled
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
