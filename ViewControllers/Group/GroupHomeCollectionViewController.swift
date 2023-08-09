//
//  GroupHomeCollectionViewController.swift
//  Groupsona
//
//  Created by Homey Poon on 2023-07-30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class GroupHomeCollectionViewController: UICollectionViewController {
    
    var group: Group!
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case groupActivityFeeds
        }
        enum Item: Hashable, Comparable {
            case groupActivityFeed(member: User, quizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .groupActivityFeed(let member, let quizHistory):
                    hasher.combine(member)
                    hasher.combine(quizHistory)
                }
            }
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.groupActivityFeed(_, let lQuizHistory), .groupActivityFeed(_, let rQuizHistory)):
                    return lQuizHistory.userCompleteTime < rQuizHistory.userCompleteTime
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.groupActivityFeed(let lMember, let lQuizHistory), .groupActivityFeed(let rMember, let rQuizHistory)):
                    return lMember == rMember && lQuizHistory == rQuizHistory
                }
            }
        }
    }
    
    struct Model {
        var members = [User]()
        var userQuizHistoriesDict = [User: [UserQuizHistory]]()
    }
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    var dataSource: DataSourceType!
    var model = Model()
    
    init?(coder: NSCoder, group: Group) {
        self.group = group
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        // Fetch the group first, and then fetch the users once the group data is available
        fetchGroup { [weak self] group in
            // Update the group variable with the fetched group data
            self?.group = group
            
            // Fetch users after getting the group data
            self?.fetchUsers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 2000, height: 40)
        button.setTitle(group?.name, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside)
        navigationItem.titleView = button
        
        navigationItem.hidesBackButton = true
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @objc func clickOnButton() {
        performSegue(withIdentifier: "showGroupSettings", sender: nil)
    }
    
    // Get all users in the group membersIDs array
    private func fetchUsers() {
        
        guard let membersIDs = group?.membersIDs else { return }
        
        self.model.members.removeAll()
        self.model.userQuizHistoriesDict.removeAll()
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        
                        self.model.members.append(member)
                        
                        let memberQuizHistory = member.userQuizHistory
                        
                        var quizHistory = [UserQuizHistory]()
                        
                        for memQuizHistory in memberQuizHistory {
                            quizHistory.append(memQuizHistory)
                        }
                        
                        self.model.userQuizHistoriesDict[member] = quizHistory
                        
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
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewListCell? in
            switch item {
            case .groupActivityFeed(let member, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupMemberQuizCell", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.cell()
                
                if let quiz = QuizData.quizzes.first(where: { $0.id == quizHistory.quizID }) {
                    content.text = "\(quiz.title)"
                    
                } else {
                    content.text = "Quiz not found"
                }
                
                content.secondaryText = "\(member.username) (\(self.timeSinceMostRecentTuesday(from: quizHistory.userCompleteTime)))"
                content.image = UIImage(systemName: "questionmark.circle.fill")
                cell.accessories = [.disclosureIndicator()]
                
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
                
                return cell
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            // Group Activity Feed section
            if sectionIndex == 0 && self.model.members.count > 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            } else {
                // Empty Section (placeholder
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        
        // Create an array of ViewModel.Item based on the data in userQuizHistoriesDict
        let groupActivityFeedItems = model.userQuizHistoriesDict.flatMap { (member, quizHistories) -> [ViewModel.Item] in
            return quizHistories.map { quizHistory -> ViewModel.Item in
                return ViewModel.Item.groupActivityFeed(member: member, quizHistory: quizHistory)
            }
        }
        
        sectionIDs.append(.groupActivityFeeds)
        
        // Changed
        let itemsBySection = [ViewModel.Section.groupActivityFeeds: groupActivityFeedItems.sorted(by: <)]

        
        // Apply the snapshot to the data source
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
    
    // Get the time since most recent Tuesday that has passed (T-day)
    func timeSinceMostRecentTuesday(from userCompleteTime: Date) -> String {
        let calendar = Calendar.current
        
        // Get the current date and time
        let currentDate = Date()
        
        // Find the most recent past Tuesday from the current date
        let components = calendar.dateComponents([.weekday], from: currentDate)
        let currentWeekday = components.weekday!
        let daysUntilTuesday = (9 - currentWeekday) % 7 // 9 represents Tuesday in DateComponents.weekday format (Sunday is 1, Monday is 2, ..., Saturday is 7)
        let mostRecentPastTuesday = calendar.date(byAdding: .day, value: -daysUntilTuesday, to: currentDate)!
        
        // Calculate the time difference between userCompleteTime and the most recent past Tuesday
        let timeDifference = calendar.dateComponents([.day, .hour], from: mostRecentPastTuesday, to: userCompleteTime)
        
        if let days = timeDifference.day, days >= 1 {
            // If it has been at least 24 hours, show the amount of days past
            return "\(days) days"
        } else {
            // Otherwise, show how many hours have passed
            if let hours = timeDifference.hour {
                return "\(hours) hours"
            } else {
                return "Less than an hour"
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .groupActivityFeed(let member, let quizHistory):
                self.performSegue(withIdentifier: "showMemberQuiz", sender: (member, quizHistory))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showGroupSettings" {
            let groupSettingsVC = segue.destination as! GroupSettingsViewController
            groupSettingsVC.members = self.model.members
            groupSettingsVC.group = self.group
        } else if segue.identifier == "showMemberQuiz" {
            let memberQuizVC = segue.destination as! GuessQuizViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let member = senderInfo.0
                let quizHistory = senderInfo.1
                memberQuizVC.members = self.model.members
                memberQuizVC.guessedMember = member
                memberQuizVC.userQuizHistory = quizHistory
                memberQuizVC.group = self.group
            }
        }
    }
    
    private func fetchGroup(completion: @escaping (Group?) -> Void) {
        guard let groupID = group?.id else {
            completion(nil)
            return
        }
        
        FirestoreService.shared.db.collection("groups").document(groupID).getDocument { (documentSnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
                completion(nil)
            } else {
                do {
                    let group = try documentSnapshot?.data(as: Group.self)
                    completion(group)
                } catch {
                    self.presentErrorAlert(with: error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
}
