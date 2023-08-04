//
//  GroupSettingsViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-01.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupSettingsCellDelegate {
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.group?.name
        
        tableView.delegate = self
        tableView.dataSource = self
        
        members.sort(by: { $0.uid == group?.leader ? true : $1.uid == group?.leader ? false : $0.username < $1.username })
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSettingsCell", for: indexPath) as! GroupSettingsTableViewCell
        
        cell.delegate = self
        
        let member = members[indexPath.row]
        
        cell.configure(withMember: member, withGroupLeader: group?.leader, withEmojis: member.quizHistory.compactMap { String($0.finalResult.emoji) }.joined(separator: " "))
        
        
        return cell
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
    
    @IBSegueAction func showMemberProfile(_ coder: NSCoder, sender: UITableViewCell?) -> ProfileViewController? {
        guard let cell = sender,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        
        let member = members[indexPath.row]
        return ProfileViewController(coder: coder, user: member)
    }
    
}
