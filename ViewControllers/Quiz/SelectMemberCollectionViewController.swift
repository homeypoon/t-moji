//
//  SelectMemberCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-08.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class SelectMemberCollectionViewController: UICollectionViewController {
    
    var quiz: Quiz?
    var currentUser: User!
    var quizHistory: QuizHistory!
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case memberSelections
            case guessedMembers
        }
        
        enum Item: Hashable {
            case memberSelection(tmate: User, userQuizHistory: UserQuizHistory)
            case guessedMember(tmate: User, userQuizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .memberSelection(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .guessedMember(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.memberSelection(let lTmate, let lUserQuizHistory), .memberSelection(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.guessedMember(let lTmate, let lUserQuizHistory), .guessedMember(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
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
        
        fetchQuizHistory { [weak self] in
            if let masterGroupmatesIDs = self?.currentUser?.masterGroupmatesIDs, !masterGroupmatesIDs.isEmpty {
                print("masterGroupmatesIDs\(masterGroupmatesIDs)")
                self!.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
            }
        }
        
        updateCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
            
            switch item {
            case .memberSelection(let tmate, let userQuizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuessSelectMember", for: indexPath) as! GuessSelectMemberCollectionViewCell
                cell.configure(withUsername: tmate.username, withTimePassed: Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                return cell
            case .guessedMember(let tmate, let userQuizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedSelectMember", for: indexPath) as! RevealedSelectMemberCollectionViewCell
                
                cell.configure(withUsername: tmate.username, withResultType: userQuizHistory.finalResult, withTimePassed: Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .guessedMembers:
                sectionHeader.configure(title: "Guessed Results", colorName: "Text")
            case .memberSelections:
                sectionHeader.configure(title: "Unguessed Results", colorName: "Text")
            }
            
            return sectionHeader
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            let horzSpacing: CGFloat = 20
            
            let sectionHeaderItemSize =
            NSCollectionLayoutSize(widthDimension:
                    .fractionalWidth(1), heightDimension: .estimated(48))
            let sectionHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
            let sectionEdgeInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
            
            // Guess Select Member
            if sectionIndex == 0  {
                let vertSpacing: CGFloat = 10
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = sectionEdgeInsets
                
                return section
            } else  {
                let vertSpacing: CGFloat = 10
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = sectionEdgeInsets
                
                return section
            }
        }
    }
    
    
    
    func updateCollectionView() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.memberSelections)
        sectionIDs.append(.guessedMembers)
        
        
        print("model.usersss \(model.userMasterTmates)")
        
        for userMasterTmate in model.userMasterTmates {
            
            // if the userMasterTmate has completed the quiz
            if quizHistory!.completedUsers.contains(userMasterTmate.uid) {
                
                // Ensure the userMasterTmate has a matching quiz history
                if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                    // if user has guessed
                    if matchingQuizHistory.membersGuessed.contains(currentUid) {
                        itemsBySection[.guessedMembers, default: []].append(ViewModel.Item.guessedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                    } else {
                        itemsBySection[.memberSelections, default: []].append(ViewModel.Item.memberSelection(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                    }
                }
            }
        }
        
        print("myitems \(itemsBySection)")
        
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
    
    private func fetchUserMasterTmates(membersIDs: [String]) {
        self.model.userMasterTmates.removeAll()
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    print("new")
                    do {
                        let member = try document.data(as: User.self)
                        self.model.userMasterTmates.append(member)
                        print("new member \(member)")
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .memberSelection(let tmate, let userQuizHistory):
                self.performSegue(withIdentifier: "guessForTmate", sender: (tmate, userQuizHistory))
            case .guessedMember(let tmate, let userQuizHistory):
                self.performSegue(withIdentifier: "showResultFromSelectMember", sender: (tmate, userQuizHistory))
                print("tmatee \(tmate)")
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "guessForTmate" {
            let guessQuizVC = segue.destination as! GuessQuizViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let guessedMember = senderInfo.0
                let userQuizHistory = senderInfo.1
                
                guessQuizVC.guessedMember = guessedMember
                guessQuizVC.userQuizHistory = userQuizHistory
            }
            
            //            self.navigationController?.popViewController(animated: true)
        } else if segue.identifier == "showResultFromSelectMember" {
            let quizResultVC = segue.destination as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let tmate = senderInfo.0
                let userQuizHistory = senderInfo.1
                
                print("tmatee2 \(tmate)")
                
                quizResultVC.quiz = self.quiz
                quizResultVC.currentUser = tmate
                quizResultVC.userQuizHistory = userQuizHistory
            }
        }
    }
}
