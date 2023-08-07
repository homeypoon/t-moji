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
    var currentUser: User?
    var userQuizHistory: UserQuizHistory?
    
    var quizHistory: QuizHistory?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case currentUserResult
            case membersResults
            case otherTmatesResults
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
    
    struct Model {
        var userMasterTmates = [User]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("current user\(currentUser)")
        print("group\(group)")
        fetchQuizHistory { [weak self] in
            
            self!.fetchUsers(membersIDs: Array(Set(self!.currentUser!.masterGroupmatesIDs)))
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
    
//    func updateCollectionView() {
//
//        var sectionIDs = [ViewModel.Section]()
//
//        sectionIDs.append(.currentUserResult)
//        var itemsBySection = [ViewModel.Section.currentUserResult: [ViewModel.Item.currentUserResult(member: currentUser!, quizHistory: userQuizHistory!)]]
//        print(itemsBySection)
//
//        guard let quizHistory = quizHistory, let currentUser = currentUser else {return }
//
//            let completedMasterTmates = model.userMasterTmates.filter { quizHistory.completedUsers.contains($0.uid) }
//
//            let incompletedMasterTmates = model.userMasterTmates.filter { !quizHistory.completedUsers.contains($0.uid) }
//
//
//        // Check if the current user's ID is in the membersGuessed array of each member
//        for userMasterTmate in model.userMasterTmates {
//            if let group = group {
//                group.membersIDs.map { $0 = com}
//
//            }
//            let isCurrentUserGuessed = completedTmate.quizHistory.contains { quizHistory in
//                quizHistory.membersGuessed.contains { $0.uid == currentUser.uid }
//            }
//
//            // Create the appropriate item based on whether the current user's ID is in membersGuessed or not
//            if isCurrentUserGuessed {
//                for quizHistory in member.quizHistory {
//                    itemsBySection[.othersResults, default: []].append(ViewModel.Item.revealedResult(member: member, quizHistory: quizHistory))
//                }
//            } else {
//                itemsBySection[.othersResults, default: []].append(ViewModel.Item.unrevealedResult(member: member))
//            }
//        }
//
//        // Add the othersResults section and its corresponding items
//        sectionIDs.append(.othersResults)
//        if let othersResultsItems = itemsBySection[.othersResults] {
//            itemsBySection[.othersResults] = othersResultsItems.sorted() // Optional: Sort the items if necessary
//        }
//
//        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
//    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()

        sectionIDs.append(.currentUserResult)
        itemsBySection[.currentUserResult] = [ViewModel.Item.currentUserResult(member: currentUser!, quizHistory: userQuizHistory!)]

        sectionIDs.append(.membersResults)
        sectionIDs.append(.otherTmatesResults)

        for userMasterTmate in model.userMasterTmates {
            if let group = group, group.membersIDs.contains(userMasterTmate.uid) {
                if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                    if matchingQuizHistory.membersGuessed.contains(userMasterTmate.uid) {
                        itemsBySection[.membersResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                    } else {
                        itemsBySection[.membersResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                    }
                }
            } else {
                if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                    if matchingQuizHistory.membersGuessed.contains(userMasterTmate.uid) {
                        itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                    } else {
                        itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                    }
                }
            }
        }

        // Sort and update the dataSource
        if let membersResultsItems = itemsBySection[.membersResults] {
            itemsBySection[.membersResults] = membersResultsItems.sorted() // Optional: Sort the items if necessary
        }

        if let otherTmatesResultsItems = itemsBySection[.otherTmatesResults] {
            itemsBySection[.otherTmatesResults] = otherTmatesResultsItems.sorted() // Optional: Sort the items if necessary
        }

        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)

    }
    
    
    
    func fetchQuizHistory(completion: @escaping () -> Void) {
        guard let quizID = quiz?.id else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quizID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
                completion()
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.quizHistory = try document.data(as: QuizHistory.self)
                        completion()
                    } catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                        completion()
                    }
                }
            }
        }
    }
    
    private func fetchUsers(membersIDs: [String]) {
        self.model.userMasterTmates.removeAll()
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        self.model.userMasterTmates.append(member)
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                self.updateCollectionView()
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissResultPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
}
