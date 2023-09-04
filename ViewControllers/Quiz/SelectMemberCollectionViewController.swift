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
            case noTmatesTaken
        }
        
        enum Item: Hashable {
            case memberSelection(tmate: User, userQuizHistory: UserQuizHistory)
            case guessedMember(tmate: User, userQuizHistory: UserQuizHistory)
            case noTmatesTaken
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .memberSelection(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .guessedMember(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .noTmatesTaken:
                    hasher.combine("Not taken by any t-mates yet")
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.memberSelection(let lTmate, let lUserQuizHistory), .memberSelection(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.guessedMember(let lTmate, let lUserQuizHistory), .guessedMember(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.noTmatesTaken, .noTmatesTaken):
                    return true
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
    var loadingSpinner: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchQuizHistory { [weak self] in
            if let masterGroupmatesIDs = self?.currentUser?.masterGroupmatesIDs, !masterGroupmatesIDs.isEmpty {
                print("masterGroupmatesIDs\(masterGroupmatesIDs)")
                self!.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
            }
        }
        
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
            case .noTmatesTaken:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoTmatesTaken", for: indexPath) as! NoTmatesTakenCollectionViewCell
                cell.configure()
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
            case .noTmatesTaken:
                sectionHeader.configure(title: "T-mate Results", colorName: "Text")
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
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }


                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                section.interGroupSpacing = vertSpacing
                
                                
                return section
            } else if sectionIndex == 1 {
                // Revealed Select Member
                let vertSpacing: CGFloat = 10
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                section.interGroupSpacing = vertSpacing
                
                return section
            } else {
                // No tmates taken
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(48))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: Padding.smallItemVertPadding,
                    trailing: 0
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: SupplementaryViewKind.sectionBackgroundView)
                
                backgroundItem.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
                
                section.decorationItems = [backgroundItem]
                                    
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 12,
                    leading: 40,
                    bottom: 40,
                    trailing: 40
                )
                
                return section
            }
        }
    }

    
    
    func updateCollectionView() {
        self.loadingSpinner?.stopAnimating()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.memberSelections)
        sectionIDs.append(.guessedMembers)
        
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
        
        if itemsBySection[.memberSelections] == nil && itemsBySection[.memberSelections] == nil  {
            
            sectionIDs.append(.noTmatesTaken)
            
            itemsBySection[.noTmatesTaken] = [ViewModel.Item.noTmatesTaken]
        } else if let memberSelections = itemsBySection[.memberSelections], let guessedMembers = itemsBySection[.guessedMembers], memberSelections.isEmpty, guessedMembers.isEmpty {
            sectionIDs.append(.noTmatesTaken)
            
            itemsBySection[.noTmatesTaken] = [ViewModel.Item.noTmatesTaken]
        }
        
        print("myitems \(itemsBySection)")
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
            case .noTmatesTaken:
                break
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
            let navController = segue.destination as! UINavigationController
            let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let tmate = senderInfo.0
                let userQuizHistory = senderInfo.1
                
                print("tmatee2 \(tmate)")
                
                quizResultVC.quiz = self.quiz
                quizResultVC.resultUser = tmate
                quizResultVC.userQuizHistory = userQuizHistory
                quizResultVC.quizResultType = .checkOtherResult
            }
        }
    }
}
