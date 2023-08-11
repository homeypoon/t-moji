//
//  LeaderboardCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class LeaderboardCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case topThree
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case topThreeTmates(tmate: User, ordinal: String)
            case remainingTmates(tmate: User, ordinal: String)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .topThreeTmates(let tmate, _):
                    hasher.combine(tmate)
                case .remainingTmates(let tmate, _):
                    hasher.combine(tmate)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.topThreeTmates(let lTmate, _), .topThreeTmates(let rTmate, _)):
                    return lTmate == rTmate
                case (.remainingTmates(let lTmate, _), .remainingTmates(let rTmate, _)):
                    return lTmate == rTmate
                case (.remainingTmates(let lTmate, _), .topThreeTmates(let rTmate, _)):
                    return lTmate == rTmate
                case (.topThreeTmates(let lTmate, _), .remainingTmates(let rTmate, _)):
                    return lTmate == rTmate
                }
            }
        }
    }
    
    struct Model {
        var sortedUserMasterTmates = [User]() // Sorted by points
        var currentUser: User?
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCurrentUser() { user in
            self.model.currentUser = user
            
            if let masterGroupmatesIDs = self.model.currentUser?.masterGroupmatesIDs, !masterGroupmatesIDs.isEmpty {
                print("master group mates\(masterGroupmatesIDs)")
                self.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
            }
        }
        
        updateCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .topThreeTmates(let tmate, let ordinal):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopThreeLeaderboard", for: indexPath) as! TopThreeLeaderboardCollectionViewCell
                
                cell.configure(withOrdinal: ordinal, withUsername: tmate.username, withPoints: tmate.points)
                
                return cell
            case .remainingTmates(let tmate, let ordinal):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemainingLeaderboard", for: indexPath) as! RemainingLeaderboardCollectionViewCell
                
                cell.configure(withOrdinal: ordinal, withUsername: tmate.username, withPoints: tmate.points)
                
                return cell
            }
        }
        
        return dataSource
    }
    
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            
            
            // top three
            if sectionIndex == 0  {
                let vertSpacing: CGFloat = 10
                let horzSpacing: CGFloat = 12
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 0,
                    bottom: 10,
                    trailing: 0
                )

                return section
            } else {
                let vertSpacing: CGFloat = 6
                let horzSpacing: CGFloat = 12
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(82))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
            
        }
    }
    
    func updateCollectionView() {
        // Sort the user master team members by points in descending order
        let sortedUsers = model.sortedUserMasterTmates.sorted { (user1, user2) in
            if user1.points == user2.points {
                return user1.username < user2.username
            }
            return user1.points > user2.points
        }
        
        // Create the section identifiers and item arrays
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        // Add the section identifiers
        sectionIDs.append(.topThree)
        sectionIDs.append(.remaining)
        
        var currentRanking = 1
        
        // Process sorted users and use index as ranking
        for (index, user) in sortedUsers.enumerated() {
            
            // Check if this user has the same points as the next one
            if index < sortedUsers.count - 1 {
                let nextUser = sortedUsers[index + 1]
                
                if user.points == nextUser.points {
                    // Increment the ordinal only if the next user has a different point value than the one after it
                    if index < sortedUsers.count - 2 && nextUser.points != sortedUsers[index + 2].points {
                        currentRanking += 1
                    }
                } else {
                    currentRanking += 1
                }
            }
            
            let item: ViewModel.Item
            
            if index < 3 {
                item = .topThreeTmates(tmate: user, ordinal: ordinalNumber(from: currentRanking))
                itemsBySection[.topThree, default: []].append(item)
            } else {
                item = .remainingTmates(tmate: user, ordinal: ordinalNumber(from: currentRanking))
                itemsBySection[.remaining, default: []].append(item)
                
            }
        }
        
        // Update the dataSource with the sorted and ranked items
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        print(itemsBySection)
    }
    
    
    // Helper function to convert a number to its ordinal representation
    func ordinalNumber(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func fetchUserMasterTmates(membersIDs: [String]) {
        self.model.sortedUserMasterTmates.removeAll()
        
        print("membersIDS in fetchuser \(membersIDs)")
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        self.model.sortedUserMasterTmates.append(member)
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                if let currentUser = self.model.currentUser {
                    self.model.sortedUserMasterTmates.append(currentUser)
                }
                self.updateCollectionView()
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return }
        let docRef = FirestoreService.shared.db.collection("users").document(currentUserID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                completion(user)
                
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}
