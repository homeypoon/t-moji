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

class HomeCollectionViewController: UICollectionViewController, HomeTopBannerDelegate {
    func createGroupButtonPressed() {
        performSegue(withIdentifier: "showAddUsersToGroup", sender: nil)
    }
    
    
    var unwindCreatedGroup: Group?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case homeTopBanner
            case groups
            //            case activityFeed
        }
        
        enum Item: Hashable, Comparable {
            case homeTopBanner
            case group(group: Group)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .homeTopBanner:
                    hasher.combine("homeTopBanner")
                case .group(let group):
                    hasher.combine(group)
                }
            }
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.homeTopBanner, .homeTopBanner):
                    return true
                case (.group(let lGroup), .group(let rGroup)):
                    return lGroup == rGroup
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var groups = [Group]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false

        
        fetchGroups()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
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
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .homeTopBanner:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTopBanner", for: indexPath) as! HomeTopBannerCollectionViewCell
                
                cell.configure()
                cell.delegate = self
                
                return cell
            case .group(let group):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Group", for: indexPath) as! HomeGroupCollectionViewCell
                
                cell.configure(groupName: group.name)
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .groups:
                sectionHeader.configure(title: "T--ms", colorName: "Text")
                return sectionHeader
            case .homeTopBanner:
                sectionHeader.configure(title: "", colorName: "Text")
                return sectionHeader
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =  UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .homeTopBanner:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(220))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
//                group.contentInsets = NSDirectionalEdgeInsets(
//                    top: 0,
//                    leading: infoHorzSpacing,
//                    bottom: vertSpacing,
//                    trailing: infoHorzSpacing
//                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 40,
                    trailing: 0
                )
                    
                return section
            case .groups:
                
                let sectionHeaderItemSize =
                NSCollectionLayoutSize(widthDimension:
                        .fractionalWidth(1), heightDimension: .estimated(48))
                let sectionHeader =
                NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 16,
                    bottom: 10,
                    trailing: 16
                )
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.interGroupSpacing = 16
                
                return section
            }
        }
    
        return layout
    }
    
//    func updateCollectionView() {
//
//        var sectionIDs = [ViewModel.Section]()
//
//        sectionIDs.append(.homeTopBanner)
//        var itemsBySection = [ViewModel.Section.homeTopBanner: [ViewModel.Item.homeTopBanner]]
//
//
//        var itemsBySection = model.groups.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, group in
//
//            partial[.groups, default: []].append(ViewModel.Item.group(group: group))
//        }
//
//        itemsBySection = itemsBySection.mapValues { $0.sorted() }
//
//        let sectionIDs = itemsBySection.keys.sorted()
//
//        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
//
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        // Add homeTopBanner section
        sectionIDs.append(.homeTopBanner)
        itemsBySection[.homeTopBanner] = [.homeTopBanner]
        
        sectionIDs.append(.groups)
        
        for group in model.groups {
            itemsBySection[.groups, default: []].append(ViewModel.Item.group(group: group))
        }
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
        
        guard !group.membersIDs.isEmpty else { return }
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: group.membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        var currentMember = try document.data(as: User.self)
                        
                        // If the member is the one being deleted
                        if currentMember.uid == currentUid {
                            for memberID in group.membersIDs.filter({ $0 != currentUid }) {
                                
                                if let index = currentMember.masterGroupmatesIDs.firstIndex(where: { $0 == memberID }) {
                                    currentMember.masterGroupmatesIDs.remove(at: index)
                                }
                            }
                            
                            currentMember.groupsIDs = currentMember.groupsIDs.filter({$0 != groupId })
                            
                            try document.reference.setData(from: currentMember)
                            
                            //                            document.reference.updateData([
                            //                                "groupsIDs": FieldValue.arrayRemove([groupId])
                            //                            ])
                        } else {
                            if let index = currentMember.masterGroupmatesIDs.firstIndex(where: { $0 == currentUid }) {
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
        
        // Remove the user id from the group's membersIDs
        FirestoreService.shared.db.collection("groups").whereField(FieldPath.documentID(), isEqualTo: groupId).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        "membersIDs": FieldValue.arrayRemove([currentUid])
                    ])
                }
                
                self.fetchGroups()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .group(let group):
                performSegue(withIdentifier: "showGroupHome", sender: group)
            case .homeTopBanner:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showGroupHome" {
            let groupHomeVC = segue.destination as! GroupHomeCollectionViewController
            
            if let group = sender as? Group {
                groupHomeVC.group = group
            }
        }
    }
    
    
    // User exits group
    @IBAction func unwindToHomeAndLeave(segue: UIStoryboardSegue) {
        
        // If unwinding from group settings, need to delete group from user
        if let groupHomeVC = segue.source as? GroupHomeCollectionViewController {
            guard let group = groupHomeVC.group else { return }
            print("unwinded to home, group: \(groupHomeVC)")
            
            removeUserFromGroup(group: group)
            
        }
        fetchGroups()
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    }
    
}
