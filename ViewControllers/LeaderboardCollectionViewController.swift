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
                case .topThreeTmates(let tmate, let ordinal):
                    hasher.combine(tmate)
                    hasher.combine(ordinal)
                case .remainingTmates(let tmate, let ordinal):
                    hasher.combine(tmate)
                    hasher.combine(ordinal)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.topThreeTmates(let lTmate, let lOrdinal), .topThreeTmates(let rTmate, let rOrdinal)):
                    return lTmate == rTmate && lOrdinal == rOrdinal
                case (.remainingTmates(let lTmate, let lOrdinal), .remainingTmates(let rTmate, let rOrdinal)):
                    return lTmate == rTmate && lOrdinal == rOrdinal
                case (.remainingTmates(let lTmate, let lOrdinal), .topThreeTmates(let rTmate, let rOrdinal)):
                    return lTmate == rTmate && lOrdinal == rOrdinal
                case (.topThreeTmates(let lTmate, let lOrdinal), .remainingTmates(let rTmate, let rOrdinal)):
                    return lTmate == rTmate && lOrdinal == rOrdinal
                }
            }
        }
    }
    
    struct Model {
        var sortedGlobalUsers = [User]()
        var sortedUserMasterTmates = [User]() // Sorted by points
        var currentUser: User?
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    var selectedSegmentIndex: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCurrentUser() { user in
            self.model.currentUser = user
            
            self.fetchGlobalUsers()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentedControl = UISegmentedControl(items: ["Global", "T-mates"])
        segmentedControl.selectedSegmentIndex = 0  // Set the default selected segment index
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        // Add the segmented control to the navigation bar
        navigationItem.titleView = segmentedControl
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

        updateCollectionView()
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
                    bottom: 0,
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
    
    // Method to update rankings for teammates
    func updateRankingsForTmates() {
        // Update teamMembers array based on points
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        print("self group mates\(self.model.currentUser?.masterGroupmatesIDs)")
        if let masterGroupmatesIDs = self.model.currentUser?.masterGroupmatesIDs {
            
            print("model.sortedgloballll \(model.sortedGlobalUsers)")
            model.sortedUserMasterTmates = model.sortedGlobalUsers.filter { user in
                user.masterGroupmatesIDs.contains(currentUid) || user.uid == currentUid
            }
            
            print("master group mates\(model.sortedUserMasterTmates)")
        } else {
            if let currentUser = self.model.currentUser {
                model.sortedUserMasterTmates = [currentUser]
            }
    
        }
    }
    
    func updateCollectionView() {
        // Sort the user master team members by points in descending order
        
        var sortedUsers: [User]
        
        if selectedSegmentIndex == 0 {
            // Use the global array for "Global" tab
            sortedUsers = model.sortedGlobalUsers
        } else {
            // Use the teammates array for "Teammates" tab
            updateRankingsForTmates()
            sortedUsers = model.sortedUserMasterTmates
        }
        
        sortedUsers = sortedUsers.sorted { (user1, user2) in
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
        var previousUserPoints: Int?

        for (index, user) in sortedUsers.enumerated() {
            if let previousPoints = previousUserPoints, user.points != previousPoints, index != 0 {
                currentRanking += 1
            }
            
            print("indexxx \(index) user \(user) ranking \(currentRanking)")

            
            let item: ViewModel.Item
            
            if index < 3 {
                item = .topThreeTmates(tmate: user, ordinal: ordinalNumber(from: currentRanking))
                itemsBySection[.topThree, default: []].append(item)
            } else {
                item = .remainingTmates(tmate: user, ordinal: ordinalNumber(from: currentRanking))
                itemsBySection[.remaining, default: []].append(item)
            }
            
            previousUserPoints = user.points
        }
        
        // Update the dataSource with the sorted and ranked items
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        print(itemsBySection)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .remainingTmates(let tmate, _):
                self.performSegue(withIdentifier: "showLeaderboardUserProfile", sender: tmate)
                
            case .topThreeTmates(let tmate, _):
                self.performSegue(withIdentifier: "showLeaderboardUserProfile", sender: tmate)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showLeaderboardUserProfile" {
            let profileVC = segue.destination as! ProfileCollectionViewController
            
            if let senderInfo = sender as? User {
                let tmate = senderInfo
                
                profileVC.otherUser = tmate
                print("other userrr\(tmate)")
            }
        }
    }
    
    
    // Helper function to convert a number to its ordinal representation
    func ordinalNumber(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func fetchGlobalUsers() {
        self.model.sortedGlobalUsers.removeAll()
        self.model.sortedUserMasterTmates.removeAll()
        
        FirestoreService.shared.db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        self.model.sortedGlobalUsers.append(member)
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
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
                self.updateCollectionView()
                
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
