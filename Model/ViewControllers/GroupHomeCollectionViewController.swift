//
//  GroupHomeCollectionViewController.swift
//  Groupsona
//
//  Created by Homey Poon on 2023-07-30.
//

import UIKit

private let reuseIdentifier = "Cell"

class GroupHomeCollectionViewController: UICollectionViewController {
    
    var group: Group?
    

    enum ViewModel {
        enum Section: Hashable, Comparable {
            case groupActivityFeeds
        }
        enum Item: Hashable {
            case groupActivityFeed(member: User, quizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .groupActivityFeed(let member, let quizHistory):
                    hasher.combine(member)
                    hasher.combine(quizHistory)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
        
        fetchUsers()
    }
    
    // Get all users in the group membersIDs array
    private func fetchUsers() {
        
        guard let membersIDs = group?.membersIDs else { return }
        print(membersIDs)
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        
                        self.model.members.append(member)
                        
                        let memberQuizHistory = member.quizHistory
                        
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
                                
                QuizData.quizzes.forEach { print($0.id) }
                if let quiz = QuizData.quizzes.first(where: { $0.id == quizHistory.quizID }) {
                    print(quiz)
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
        
//        var groupActivityFeedItems: [ViewModel.Item] = []
        
//        model.userQuizHistoriesDict.forEach { (member, quizHistories) in
//
//            for quizHistory in quizHistories {
//                groupActivityFeedItems.append(ViewModel.Item.groupActivityFeed(member: member, quizHistory: quizHistory))
//            }
//        }
        
        // Create an array of ViewModel.Item based on the data in userQuizHistoriesDict
        let groupActivityFeedItems = model.userQuizHistoriesDict.flatMap { (member, quizHistories) -> [ViewModel.Item] in
            return quizHistories.map { quizHistory -> ViewModel.Item in
                return ViewModel.Item.groupActivityFeed(member: member, quizHistory: quizHistory)
            }
        }
        
        sectionIDs.append(.groupActivityFeeds)
        
        let itemsBySection = [ViewModel.Section.groupActivityFeeds: groupActivityFeedItems]
        
        // Apply the snapshot to the data source
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func addGroup(group: Group) {
        
        let collectionRef = FirestoreService.shared.db.collection("groups")
        
        do {
            try collectionRef.addDocument(from: group)
        }
        catch {
            print(error)
        }
    }
    
    // Get the time since most recent Tuesday that has passed (T-day)
    func timeSinceMostRecentTuesday(from userCompleteTime: Date) -> String {
        let calendar = Calendar.current
        
        // Get the current date and time
        let currentDate = Date()
        
        // Find the most recent past Tuesday from the current date
        var components = calendar.dateComponents([.weekday], from: currentDate)
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
    
}
