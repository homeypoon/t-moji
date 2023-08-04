//
//  QuizResultCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

private let reuseIdentifier = "Cell"

class QuizResultCollectionViewController: UICollectionViewController {
    var quiz: Quiz?
    var group: Group?
    var members = [User]()
    var currentMember: User?
    var quizHistory: UserQuizHistory?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case currentUserResult
            case othersResults
        }
        
        enum Item: Hashable, Comparable {
            case currentUserResult(member: User, quizHistory: UserQuizHistory)
            case revealedResult(member: User, quizHistory: UserQuizHistory)
            case unrevealedResult(member: User)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .currentUserResult(let member, let quizHistory):
                    hasher.combine(member)
                    hasher.combine(quizHistory)
                    
                case .revealedResult(let member, let quizHistory):
                    hasher.combine(member)
                    hasher.combine(quizHistory)
                    
                case .unrevealedResult(let member):
                    hasher.combine(member)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.currentUserResult(let lMember, let lQuizHistory), .currentUserResult(let rMember, let rQuizHistory)):
                    return lMember == rMember && lQuizHistory == rQuizHistory
                case (.revealedResult(member: let lMember, quizHistory: let lQuizHistory), .revealedResult(member: let rMember, quizHistory: let rQuizHistory)):
                    return lMember == rMember && lQuizHistory == rQuizHistory
                case (.unrevealedResult(let lMember), .unrevealedResult(let rMember)):
                    return lMember == rMember
                default:
                    return false
                }
            }
        }
    }
    
    
    var dataSource: DataSourceType!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            case .currentUserResult(_, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentUserResult", for: indexPath) as! CurrentUserResultCollectionViewCell
                
                cell.configure(withQuizTitle: self.quiz?.title, withResultType: quizHistory.finalResult)
                
                return cell
            case .revealedResult(let member, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedResult", for: indexPath) as! RevealedResultCollectionViewCell
                
                cell.configure(withUsername: member.username, withResultType: quizHistory.finalResult)
                
                return cell
            case .unrevealedResult(let member):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnrevealedResult", for: indexPath) as! UnrevealedResultCollectionViewCell
                
                cell.configure(withUsername: member.username)
                
                return cell
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            // Current User Result
            if sectionIndex == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(410))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // Here we use 'count' parameter to specify the number of items per group, which is 2 in this case.
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(320))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2) // Use count: 2 to have two items per group.
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        
        var sectionIDs = [ViewModel.Section]()
        
        sectionIDs.append(.currentUserResult)
        var itemsBySection = [ViewModel.Section.currentUserResult: [ViewModel.Item.currentUserResult(member: currentMember!, quizHistory: quizHistory!)]]
        print(itemsBySection)
        
        // Check if the current user's ID is in the membersGuessed array of each member
        for member in members.filter({ $0.uid != currentMember?.uid }) {
            let isCurrentUserGuessed = member.quizHistory.contains { quizHistory in
                quizHistory.membersGuessed.contains { $0.uid == currentMember?.uid }
            }
            
            // Create the appropriate item based on whether the current user's ID is in membersGuessed or not
            if isCurrentUserGuessed {
                for quizHistory in member.quizHistory {
                    itemsBySection[.othersResults, default: []].append(ViewModel.Item.revealedResult(member: member, quizHistory: quizHistory))
                }
            } else {
                itemsBySection[.othersResults, default: []].append(ViewModel.Item.unrevealedResult(member: member))
            }
        }
        
        // Add the othersResults section and its corresponding items
        sectionIDs.append(.othersResults)
        if let othersResultsItems = itemsBySection[.othersResults] {
            itemsBySection[.othersResults] = othersResultsItems.sorted() // Optional: Sort the items if necessary
        }
        
        //        let othersResultsItems = members.reduce(into: [ViewModel.Item]()) { partial, member in
        //            member.quizHistory.membersGuessed
        //                let item = ViewModel.Item.emoji(resultType: resultType)
        //                partial.append(item)
        //            }
        
        //        let resultTypeItems = model.resultTypes.reduce(into: [ViewModel.Item]()) { partial, resultType in
        //            let item = ViewModel.Item.emoji(resultType: resultType)
        //            partial.append(item)
        //        }
        //
        //        sectionIDs.append(.userEmojis)
        //
        //        itemsBySection[.userEmojis] = resultTypeItems
        //
        //
        //        let quizHistoryItems = model.userQuizHistory.reduce(into: [ViewModel.Item]()) { partial, quizHistory in
        //            let item = ViewModel.Item.quizHistory(quizHistory: quizHistory)
        //            partial.append(item)
        //        }
        //
        //        sectionIDs.append(.userQuizHistory)
        //        itemsBySection[.userQuizHistory] = quizHistoryItems
        //
        //        print("itemsBySection \(itemsBySection)")
        //
        //
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
}
