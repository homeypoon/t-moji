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
            case noGroups
        }
        
        enum Item: Hashable, Comparable {
            case homeTopBanner
            case group(group: Group)
            case noGroups
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .homeTopBanner:
                    hasher.combine("homeTopBanner")
                case .group(let group):
                    hasher.combine(group)
                case .noGroups:
                    hasher.combine("No Groups")
                }
            }
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.homeTopBanner, .homeTopBanner):
                    return true
                case (.group(let lGroup), .group(let rGroup)):
                    return lGroup == rGroup
                case (.noGroups, .noGroups):
                    return true
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
    var loadingSpinner: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        fetchGroups()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner?.center = view.center
        loadingSpinner?.hidesWhenStopped = true
        if let loadingSpinner = loadingSpinner {
            view.addSubview(loadingSpinner)
            
            loadingSpinner.startAnimating()
        }
        
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
                self.loadingSpinner?.stopAnimating()
                self.presentErrorAlert(with: "A network error occured!")
            } else {
                self.model.groups.removeAll()
                
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: Group.self)
                        
                        self.model.groups.append(group)
                    }
                    catch {
                        self.loadingSpinner?.stopAnimating()
                        self.presentErrorAlert(with: "An error occured!")
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
                
                cell.configure(groupName: group.name, groupEmoji: group.emoji)
                
                return cell
            case .noGroups:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoGroups", for: indexPath) as! NoGroupsCollectionViewCell
                
                cell.configure()
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .groups:
                sectionHeader.configureBigHeader(title: "T--ms", colorName: "Text")
                return sectionHeader
            case .homeTopBanner:
                sectionHeader.configure(title: "", colorName: "Text")
                return sectionHeader
            case .noGroups:
                sectionHeader.configure(title: "T--ms", colorName: "Text")
                return sectionHeader
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =  UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            let sectionHeaderItemSize =
            NSCollectionLayoutSize(widthDimension:
                    .fractionalWidth(1), heightDimension: .estimated(48))
            let sectionHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
            
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .homeTopBanner:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(170))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
                
                return section
            case .groups:
                
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
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 24,
                    bottom: 10,
                    trailing: 24
                )
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.interGroupSpacing = 16
                
                return section
            case .noGroups:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(147))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                let section = NSCollectionLayoutSection(group: group)

                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 24, bottom: 20, trailing: 24)
                
                return section
                
            }
        }
        
        return layout
    }
    
    func updateCollectionView() {
        self.loadingSpinner?.stopAnimating()
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        // Add homeTopBanner section
        sectionIDs.append(.homeTopBanner)
        itemsBySection[.homeTopBanner] = [.homeTopBanner]
        
        sectionIDs.append(.groups)
        
        for group in model.groups {
            itemsBySection[.groups, default: []].append(ViewModel.Item.group(group: group))
        }
        
        if itemsBySection[.groups] == nil  {
            sectionIDs.append(.noGroups)
            itemsBySection[.noGroups] = [ViewModel.Item.noGroups]
        } else if let quizzes = itemsBySection[.groups], quizzes.isEmpty {
            sectionIDs.append(.noGroups)
            itemsBySection[.noGroups] = [ViewModel.Item.noGroups]
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
            case .noGroups:
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
