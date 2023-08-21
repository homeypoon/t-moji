//
//  GroupSettingsViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-01.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupSettingsCellDelegate, AddTmatesButtonTableViewCellDelegate {
        
    
    func manageMemberButtonTapped(sender: GroupSettingsTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let member = members[indexPath.row]
            presentMemberActionSheet(withMember: member, withUsername: member.username)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var members = [User]()
    var group: Group?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("membersss \(members)")
        
        fetchGroup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
                // Add tmates button
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddTmatesButtonCell", for: indexPath) as! AddTmatesButtonTableViewCell
                cell.delegate = self
                return cell
            } else {
                // Group settings cells
                let adjustedIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSettingsCell", for: indexPath) as! GroupSettingsTableViewCell
                cell.delegate = self
                let member = members[adjustedIndexPath.row]
                cell.configure(withMember: member, withGroupLeader: group?.leader, withEmojis: member.userQuizHistory.compactMap { String($0.finalResult.emoji) }.joined(separator: " "))
                return cell
            }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentMemberActionSheet(withMember member: User, withUsername username: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove \(username) From Group", style: .default, handler: { action in
            self.removeUserFromGroup(member: member)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MAJOR EDITS
    func removeUserFromGroup(member: User) {
        guard let groupId = self.group?.id,
        let membersIDs = self.group?.membersIDs else { return }
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        var currentMember = try document.data(as: User.self)
                        
                        // If the member is the one being deleted
                        if currentMember.uid == member.uid {
                            document.reference.updateData([
                                "groupsIDs": FieldValue.arrayRemove([groupId])
                            ])
                        } else {
                            if let index = currentMember.masterGroupmatesIDs.firstIndex(where: { $0 == member.uid }) {
                                currentMember.masterGroupmatesIDs.remove(at: index)
                            }
                            try document.reference.setData(from: currentMember) // Use setData on DocumentReference
                        }
                    } catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                
            }
        }
        
        // Remove the group id from the current user's group IDs list
        FirestoreService.shared.db.collection("users").whereField("uid", isEqualTo: member.uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        "groupsIDs": FieldValue.arrayRemove([groupId])
                    ])
                }
                
            }
        }
        
        // Remove the user id from the group's membersIDs
        FirestoreService.shared.db.collection("groups").whereField(FieldPath.documentID(), isEqualTo: groupId).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        "membersIDs": FieldValue.arrayRemove([member.uid])
                    ])
                }
                
                if let index = self.members.firstIndex(where: { $0.uid == member.uid }) {
                    // Remove the member from the 'members' array
                    self.members.remove(at: index)
                    // Delete the corresponding row in the table view
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBSegueAction func showMemberProfile(_ coder: NSCoder, sender: UITableViewCell?) -> ProfileCollectionViewController? {
        guard let cell = sender,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        
        let member = members[indexPath.row]
        return ProfileCollectionViewController(coder: coder, user: member)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showAddTmates" {
//            let navController = segue.destination as! UINavigationController
//            let addUsersVC = navController.topViewController as! AddUsersCollectionViewController
            
            let addUsersVC = segue.destination as! AddUsersCollectionViewController
            
            addUsersVC.group = group
            
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            addUsersVC.membersIDs = members.map { $0.uid }
            
//            addUsersVC
                
//                guessQuizVC.guessedMember = tmate
//                guessQuizVC.userQuizHistory = userQuizHistory
//                guessQuizVC.group = group
            
        }
    }
    
    func addTmatesButtonTapped() {
        performSegue(withIdentifier: "showAddTmates", sender: nil)
    }
    
    private func fetchGroup() {
        guard let groupID = group?.id else { return }
        
        let docRef = FirestoreService.shared.db.collection("groups").document(groupID)
        
        docRef.getDocument(as: Group.self) { result in
            switch result {
            case .success(let group):
                
                self.group = group
                self.navigationItem.title = self.group?.name
                
                self.fetchMembers(membersIDs: group.membersIDs)
                
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
    private func fetchMembers(membersIDs: [String]) {
        self.members.removeAll()
        
        guard !membersIDs.isEmpty else { return }
        
        print("membersIDS in fetchuser \(membersIDs)")
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        if !self.members.contains(member) {
                            self.members.append(member)
                        }
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                
                self.members.sort(by: { $0.uid == self.group?.leader ? true : $1.uid == self.group?.leader ? false : $0.username < $1.username })
                self.tableView.reloadData()
                print("reload")
            }
        }
    }

    @IBAction func unwindToGroupSettings(segue: UIStoryboardSegue) {
    }
}
