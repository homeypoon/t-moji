//
//  AddUsersCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-16.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private let reuseIdentifier = "Cell"

class AddUsersCollectionViewController: UICollectionViewController, GroupNameCollectionViewCellDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            // No search text, handle as needed
            return
        }
        
        if searchText.isEmpty {
            
            updateCollectionView()
            
            
        } else {
            
            model.selectedUsers = model.users.filter { model.userSelectedState[$0.uid] ?? false }
            
            var filteredUsers = model.allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) } + model.selectedUsers
            
            filteredUsers = model.selectedUsers + filteredUsers.filter { !model.selectedUsers.contains($0) }

            
            // Update the collection view with filtered results
            updateCollectionView(filteredUsers: filteredUsers)
            
//
//            model.selectedUsers = model.users.filter { model.userSelectedState[$0.uid] ?? false }
//
//            let filteredUsers = model.allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
//
//            model.users = model.selectedUsers + filteredUsers.filter { !model.selectedUsers.contains($0) }
//
//            model.users = model.allUsers // Restore the original list when search text is empty
            
        }
//        updateCollectionView()
    }
    
    var group: Group?
    var membersIDs: [String]?
    
    var groupName: String = ""
    
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var createBarButton: UIBarButtonItem!
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case groupName
            case users
        }
        enum Item: Hashable {
            case groupName
            case selectedUser(user: User)
            case unselectedUser(user: User)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .groupName:
                    hasher.combine("groupName")
                case .selectedUser(let user):
                    hasher.combine(user.uid)
                case .unselectedUser(let user):
                    hasher.combine(user.uid)
                }
                
            }
            
            static func == (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.groupName, .groupName):
                    return true
                case let (.selectedUser(user1), .selectedUser(user2)):
                    return user1 == user2
                case let (.unselectedUser(user1), .unselectedUser(user2)):
                    return user1.uid == user2.uid
                default:
                    return false
                }
            }
            
        }
    }
    
    struct Model {
        var users = [User]()
        
        var allUsers = [User]()
        
        var selectedUsers = [User]()
        var unselectedUsers = [User]()
        
        var userSelectedState: [String: Bool] = [:]
    }
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var searchController: UISearchController!
    
    func setUpSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        // Customize search bar appearance
        searchController.searchBar.placeholder = "Search Users"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        // Add More Tmates To Edit
        if let group = group {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = self.createBarButton
            
            self.createBarButton.title = "Save"
            self.tabBarController?.navigationItem.hidesBackButton = false
            
            groupName = group.name
        } else {
            // Add User
            self.navigationItem.leftBarButtonItem = self.cancelBarButton
            self.navigationItem.rightBarButtonItem = self.createBarButton
            self.createBarButton.title = "Create"
            self.tabBarController?.navigationItem.hidesBackButton = true
            
        }
        
        fetchUsers()
        print("fetchusers")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        collectionView.register(SearchBarReusableView.self, forSupplementaryViewOfKind: SupplementaryViewKind.searchBar,  withReuseIdentifier: SearchBarReusableView.reuseIdentifier)
        
        setUpSearchController()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item {
            case .groupName:
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupName", for: indexPath) as! GroupNameCollectionViewCell
                cell.configure(groupName: self.groupName)
                
                cell.delegate = self
                
                return cell
                
            case .selectedUser(let user):
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddUser", for: indexPath) as! AddUsersCollectionViewCell
                cell.configure(withUsername: user.username, isSelected: self.model.userSelectedState[user.uid] ?? false)
                
                cell.delegate = self
                
                return cell
            case .unselectedUser(let user):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddUser", for: indexPath) as! AddUsersCollectionViewCell
                cell.configure(withUsername: user.username, isSelected: self.model.userSelectedState[user.uid] ?? false)
                cell.delegate = self
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            if kind == SupplementaryViewKind.sectionHeader {
                let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
                let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
                
                switch section {
                case .users:
                    sectionHeader.configure(title: "Add Users", colorName: "Text")
                case .groupName:
                    break
                }
                
                return sectionHeader
            }
            return nil
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let horzSpacing: CGFloat = 20
        
        let sectionHeaderItemSize =
        NSCollectionLayoutSize(widthDimension:
                .fractionalWidth(1), heightDimension: .estimated(48))
        let sectionHeader =
        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
                
            case .groupName:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(128))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                                
                return section
            case .users:
                // users
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.interGroupSpacing = 12
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: horzSpacing,
                    bottom: 10,
                    trailing: horzSpacing
                )
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
                
            }
        }
    }
    
    func updateCollectionView(filteredUsers: [User]? = nil) {
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.groupName)
        itemsBySection[.groupName, default: []].append(ViewModel.Item.groupName)
        
        sectionIDs.append(.users)
        
        let users: [User]!
        
        if let filteredUsers {
            users = filteredUsers
        } else {
            users = model.allUsers
        }
        
        for user in users {
            if model.userSelectedState[user.uid] == true {
                itemsBySection[.users, default: []].append(ViewModel.Item.selectedUser(user: user))
            } else {
                itemsBySection[.users, default: []].append(ViewModel.Item.unselectedUser(user: user))
            }
        }
        
        print("model users update \(model.users)")
        
        self.dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    // Get all users in the app (temporary - later filter for only friended users)
    private func fetchUsers() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.model.users.removeAll()
        self.model.allUsers.removeAll()
        
        if let membersIDs = self.membersIDs, !membersIDs.isEmpty {
            FirestoreService.shared.db.collection("users").whereField(FieldPath.documentID(), notIn: membersIDs).getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.presentErrorAlert(with: error.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            var user = try document.data(as: User.self)
                            
                            
                            self.model.userSelectedState[user.uid] = false
                            
                            self.model.users.append(user)
                            self.model.allUsers.append(user)
                            
                        }
                        catch {
                            self.presentErrorAlert(with: error.localizedDescription)
                        }
                        
                    }
                    self.updateSaveButtonState()
                    self.updateCollectionView()
                    print("update")
                }
            }
        } else {
            FirestoreService.shared.db.collection("users").whereField(FieldPath.documentID(), isNotEqualTo: uid).getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.presentErrorAlert(with: error.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            var user = try document.data(as: User.self)
                            
                            self.model.userSelectedState[user.uid] = false
                            
                            self.model.users.append(user)
                            self.model.allUsers.append(user)
                            
                        }
                        catch {
                            self.presentErrorAlert(with: error.localizedDescription)
                        }
                        
                    }
                    self.updateSaveButtonState()
                    self.updateCollectionView()
                    print("update")
                }
            }
        }
        
    }
    
    func updateData(groupID: String, updateGroupName: Bool, addMemberIDs: [String]) {
        guard let userId = Auth.auth().currentUser?.uid, (updateGroupName || !addMemberIDs.isEmpty) else {return}
        let collectionRef = FirestoreService.shared.db.collection("groups")
        
        collectionRef.whereField(FieldPath.documentID(), isEqualTo: groupID).getDocuments() { (querySnapshot, error) in
            if let error = error {
                self.dismiss(animated: false, completion: nil)
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                let document = querySnapshot!.documents.first
                print("doc \(document)")
                print("groupIDddd \(groupID)")
                
                if updateGroupName && !addMemberIDs.isEmpty {
                    document?.reference.updateData([
                        "name": self.groupName,
                        "membersIDs": FieldValue.arrayUnion(addMemberIDs)
                    ])
                } else if updateGroupName {
                    document?.reference.updateData([
                        "name": self.groupName
                    ])
                } else if !addMemberIDs.isEmpty {
                    document?.reference.updateData([
                        "membersIDs": FieldValue.arrayUnion(addMemberIDs)
                    ])
                }
                
            }
        }
        
        if !addMemberIDs.isEmpty {
            
            if let membersIDs = membersIDs {
                let combinedIDs = addMemberIDs + membersIDs
                
                FirestoreService.shared.db.collection("users").whereField("uid", in: combinedIDs).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        self.presentErrorAlert(with: error.localizedDescription)
                    } else {
                        for document in querySnapshot!.documents {
                            do {
                                
                                var currentMember = try document.data(as: User.self)
                                if addMemberIDs.contains(currentMember.uid) {
                                    // newly added member
                                    
                                    currentMember.masterGroupmatesIDs.append(contentsOf: membersIDs)
                                    
                                    print("member ids \(currentMember.masterGroupmatesIDs)")
                                    
                                    document.reference.updateData([
                                        "groupsIDs": FieldValue.arrayUnion([groupID]),
                                        "masterGroupmatesIDs": currentMember.masterGroupmatesIDs
                                    ])
                                } else {
                                    // existing member in group
                                    
                                    currentMember.masterGroupmatesIDs.append(contentsOf: addMemberIDs)
                                    
                                    print("member ids \(currentMember.masterGroupmatesIDs)")
                                    
                                    document.reference.updateData([
                                        "groupsIDs": FieldValue.arrayUnion([groupID]),
                                        "masterGroupmatesIDs": currentMember.masterGroupmatesIDs
                                    ])
                                }
                            } catch {
                                self.presentErrorAlert(with: error.localizedDescription)
                            }
                        }
                        
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
    
    func updateSaveButtonState() {
        
        if let group = group {
            let shouldEnableSaveButton = !groupName.isEmpty && (groupName != group.name || model.users.contains { user in
                return model.userSelectedState[user.uid] == true
            })
            createBarButton.isEnabled = shouldEnableSaveButton
        } else {
            let shouldEnableSaveButton = !groupName.isEmpty && model.users.contains { user in
                return model.userSelectedState[user.uid] == true
            }
            createBarButton.isEnabled = shouldEnableSaveButton
        }
    }
    
    @IBAction func createBarButtonClicked(_ sender: UIBarButtonItem) {
        if group != nil {
            performSegue(withIdentifier: "unwindToGroupHome", sender: nil)
        } else {
            performSegue(withIdentifier: "showGroupHome", sender: nil)
        }
    }
    
    // Prepare for the saveUnwind segue by updating User object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showGroupHome" {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            var membersIDs = model.userSelectedState
                .filter { $0.value }
                .map { $0.key }
            
            membersIDs.append(userID)
            
            self.group = Group(name: groupName, leader: userID, membersIDs: membersIDs)
            let groupId = self.addGroup(group: self.group!)
            self.group?.id = groupId
            
            let groupHomeVC = segue.destination as! GroupHomeCollectionViewController
            groupHomeVC.group = self.group
        } else if segue.identifier == "unwindToGroupHome" {
//            let groupSettingsVC = segue.destination as! GroupHomeCollectionViewController
//            groupSettingsVC.group = group
            
            var addMemberIDs = model.userSelectedState
                .filter { $0.value }
                .map { $0.key }
            
            if let groupID = group?.id {
                
                if group?.name != groupName {
                    self.updateData(groupID: groupID, updateGroupName: true, addMemberIDs: addMemberIDs)
                } else {
                    self.updateData(groupID: groupID, updateGroupName: false, addMemberIDs: addMemberIDs)
                }
            }
            
        }
    }
    
    func groupNameDidChange(to newName: String) {
        groupName = newName
        updateSaveButtonState()
    }
}

extension AddUsersCollectionViewController: AddUsersCollectionViewCellDelegate {
    func addToGroupButtonTapped(for cell: AddUsersCollectionViewCell) {
        print("preeeessed")
        if let indexPath = collectionView.indexPath(for: cell) {
            let user = model.users[indexPath.item]
            model.userSelectedState[user.uid] = !(model.userSelectedState[user.uid] ?? false) // Toggle selected state
            
            print("state \(!(model.userSelectedState[user.uid] ?? false))")
            updateSaveButtonState()
            collectionView.reloadData()
            //                updateCollectionView()
        }
    }
}
