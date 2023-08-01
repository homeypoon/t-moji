//
//  HomeCollectionViewController.swift
//  Groupsona
//
//  Created by Homey Poon on 2023-07-29.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UICollectionViewController {
    
    var unwindCreatedGroup: Group?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case groups
            //            case activityFeed
        }
        
        typealias Item = Group
    }
    
    struct Model {
        var groups = [Group]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroups()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    // Get groups whose membersIDs contains the current user's id
    private func fetchGroups() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirestoreService.shared.db.collection("groups").whereField("membersIDs", arrayContains: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                self.model.groups.removeAll()
                
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: Group.self)
                        
                        self.model.groups.append(group)
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                    
                }
                
                self.updateCollectionView()
            }
        }
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, group) -> UICollectionViewListCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Group", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.cell()
            
            content.text = "\(group.name)"
            
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
            
            return cell
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateCollectionView() {
        
        var itemsBySection = model.groups.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habitCount in
            
            partial[.groups, default: []].append(habitCount)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func removeUserFromGroup(group: Group) {
        guard let groupId = group.id,
              let currentUid = Auth.auth().currentUser?.uid else { return }
                
        // Remove the group id from the current user's group IDs list
        FirestoreService.shared.db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    print(document.reference)
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
                    print(document.reference)
                    document.reference.updateData([
                        "membersIDs": FieldValue.arrayRemove([currentUid])
                    ])
                }
                
                self.fetchGroups()
                self.collectionView.reloadData()
            }
        }
        
        
    }
    
    @IBSegueAction func showGroupHome(_ coder: NSCoder, sender: UICollectionViewCell?) -> GroupHomeCollectionViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let group = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        return GroupHomeCollectionViewController(coder: coder, group: group)
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        print("not yet")
        // If unwinding from group settings, need to delete group from user
        if let groupSettingsVC = segue.source as? GroupSettingsViewController {
            print("yes")
            guard let group = groupSettingsVC.group else { return }
            
            print("yess")
            removeUserFromGroup(group: group)
            
        }
        fetchGroups()
    }
    
}
