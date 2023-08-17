//
//  QuizResultCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

enum QuizResultType {
    case ownRetake, ownQuiz, checkOtherResult, checkOwnResult
}

class QuizResultCollectionViewController: UICollectionViewController {
    var quizResultType: QuizResultType?
    
    var quiz: Quiz?
    var group: Group?
    var members = [User]() // test delete
    var resultUser: User?
    var userQuizHistory: UserQuizHistory?
    
    var quizHistory: QuizHistory?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case quizSummary
            case currentUserResult
            case membersResults
            case otherTmatesResults
        }
        
        enum Item: Hashable, Comparable {
            case quizSummary(currentUser: User, quizHistory: UserQuizHistory)
            case currentUserResult(member: User, quizHistory: UserQuizHistory)
            case revealedResult(member: User, quizHistory: UserQuizHistory)
            case unrevealedResult(member: User)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .quizSummary(let currentUser, let quizHistory):
                    hasher.combine(currentUser)
                    hasher.combine(quizHistory)
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
                case (.quizSummary(let lMember, let lQuizHistory), .quizSummary(let rMember, let rQuizHistory)):
                    return lMember == rMember && lQuizHistory == rQuizHistory
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
        var currentUser: User?
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchQuizHistory { [weak self] in
            
            self?.fetchUser {
                if let masterGroupmatesIDs = self?.model.currentUser?.masterGroupmatesIDs.filter({ $0 != self?.resultUser?.uid }), !masterGroupmatesIDs.isEmpty {
                    print("masterGroupmatesIDs\(masterGroupmatesIDs)")
                    self!.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
                }
            }
        }
        
        
//        updateCollectionView()
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
            case .quizSummary(let currentUser, _):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizSummary", for: indexPath) as! QuizSummaryCollectionViewCell
                                
                if self.quizResultType == .ownRetake {
                    cell.configure(quizTitle: self.quiz?.title, isRetake: true, withPoints: currentUser.points)
                } else if self.quizResultType == .ownQuiz {
                    cell.configure(quizTitle: self.quiz?.title, isRetake: false, withPoints: currentUser.points)
                }
                
                
                return cell
            case .currentUserResult(_, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentUserResult", for: indexPath) as! CurrentUserResultCollectionViewCell
                
                let memberUsername = (self.quizResultType == .checkOtherResult) ? self.resultUser?.username : nil
                
                cell.configure(withQuizTitle: self.quiz?.title, withResultType: quizHistory.finalResult, memberUsername: memberUsername)
                print("configured current ")
                
                return cell
            case .revealedResult(let member, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedResult", for: indexPath) as! RevealedResultCollectionViewCell
                
                cell.configure(withUsername: member.username, withResultType: quizHistory.finalResult, isCurrentUser: member.uid == currentUid)
                print("configured revealed ")
                return cell
            case .unrevealedResult(let member):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnrevealedResult", for: indexPath) as! UnrevealedResultCollectionViewCell
                
                cell.configure(withUsername: member.username, isCurrentUser: member.uid == currentUid)
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            if section == .membersResults {
                if let group = self.group {
                    sectionHeader.configure(title: "\(group.name) T-mates Results", colorName: "Text")
                }
            } else if section == .otherTmatesResults {
                if let group = self.group {
                    sectionHeader.configure(title: "Other T-mates Results", colorName: "Text")
                } else {
                    sectionHeader.configure(title: "T-mates Results", colorName: "Text")
                }
            } else {
                sectionHeader.configure(title: "", colorName: "Text")
            }
            
            return sectionHeader
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
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
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
                
            case .quizSummary:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            case .currentUserResult:
                // Quiz Result
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(380))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [sectionHeader]
                                
                return section
            default:
                let itemSize =
                NSCollectionLayoutSize(widthDimension:
                        .fractionalWidth(1), heightDimension: .fractionalWidth(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize =
                NSCollectionLayoutSize(widthDimension:
                        .fractionalWidth(0.75), heightDimension: .estimated(250))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        
        sectionIDs.append(.quizSummary)
        
        if self.quizResultType == .ownQuiz || self.quizResultType == .ownRetake {
            if let currentUser = self.model.currentUser {
                itemsBySection[.quizSummary] = [ViewModel.Item.quizSummary(currentUser: currentUser, quizHistory: userQuizHistory!)]
            }
        }
        
        sectionIDs.append(.currentUserResult)
        itemsBySection[.currentUserResult] = [ViewModel.Item.currentUserResult(member: resultUser!, quizHistory: userQuizHistory!)]
        
        sectionIDs.append(.membersResults)
        sectionIDs.append(.otherTmatesResults)
        
        print("modeling \(self.model.userMasterTmates)")
        
        for userMasterTmate in model.userMasterTmates {
            
            // if the userMasterTmate has completed the quiz
            if quizHistory!.completedUsers.contains(userMasterTmate.uid) {
                
                // If userMasterTmate in the current group
                if let group = group, group.membersIDs.contains(userMasterTmate.uid) {
                    
                    // Ensure the userMasterTmate has a matching quiz history
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                        // if user has guessed
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            itemsBySection[.membersResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                        } else {
                            itemsBySection[.membersResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                        }
                    }
                } else {
                    // Ensure the userMasterTmate has a matching quiz history
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                        
                        // if user has guessed
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                        } else {
                            itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                        }
                    }
                }
                
            }
        }
        
        if quizResultType == .checkOtherResult {
            // if the current user has completed the quiz
            if quizHistory!.completedUsers.contains(currentUid), let currentUser = model.currentUser, let matchingQuizHistory = currentUser.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                
                if let group = self.group {
                    itemsBySection[.membersResults, default: []].append(ViewModel.Item.revealedResult(member: currentUser, quizHistory: matchingQuizHistory))
                } else {
                    itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.revealedResult(member: currentUser, quizHistory: matchingQuizHistory))
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
        
        print("itemsBySectionasdjfkf \(itemsBySection)")
        
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
        
        print("membersIDS in fetchuser \(membersIDs)")
        
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
    
    private func fetchUser(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                
                self.model.currentUser = user
                
                completion()

            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
                completion()
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .unrevealedResult(let member):
                self.performSegue(withIdentifier: "guessToRevealFromPersonal", sender: (member))
            default:
                return
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "guessToRevealFromPersonal" {
            let guessQuizVC = segue.destination as! GuessQuizViewController
            
            if let senderInfo = sender as? (User) {
                let guessedMember = senderInfo
                guessQuizVC.members = self.members
                guessQuizVC.guessedMember = guessedMember
                guessQuizVC.userQuizHistory = userQuizHistory
                guessQuizVC.group = self.group
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
