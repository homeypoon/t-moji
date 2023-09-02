//
//  GuessResultCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class GuessResultCollectionViewController: UICollectionViewController, UnrevealedResultCellDelegate {
    func guessToRevealPressed(sender: UnrevealedResultCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: sender) {
            if let item = dataSource.itemIdentifier(for: indexPath) {
                switch item {
                case .unrevealedResult(let member):
                    performSegue(withIdentifier: "guessToRevealFromGuess", sender: member)
                default:
                    return
                }
            }
        }
    }
    
    var quiz: Quiz?
    var group: Group?
    var members = [User]()
    var guessedUser: User?
    var userQuizHistory: UserQuizHistory?
    var guessedResultType: ResultType?
    var quizHistory: QuizHistory?
    var loadingSpinner: UIActivityIndicatorView?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case guessSummary
            case currentUserResult
            case membersResults
            case otherTmatesResults
        }
        
        enum Item: Hashable, Comparable {
            case guessSummary(currentUser: User, quizHistory: UserQuizHistory)
            case currentUserResult(member: User, quizHistory: UserQuizHistory)
            case revealedResult(member: User, quizHistory: UserQuizHistory)
            case unrevealedResult(member: User)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .guessSummary(let currentUser, let quizHistory):
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
                if let masterGroupmatesIDs = self?.model.currentUser?.masterGroupmatesIDs, !masterGroupmatesIDs.isEmpty {
                    self!.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
                } else {
                    self?.updateCollectionView()
                }
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
            
            let sectionHeaderItemSize =
            NSCollectionLayoutSize(widthDimension:
                    .fractionalWidth(1), heightDimension: .estimated(48))
            let sectionHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
            
            
            switch item {
            case .guessSummary(let currentUser, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuessSummary", for: indexPath) as! GuessSummaryCollectionViewCell
                cell.configure(quizTitle: self.quiz?.title, isCorrect: (self.guessedResultType == quizHistory.finalResult), withPoints: currentUser.points)
                
                return cell
                
            case .currentUserResult(_, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuessResult", for: indexPath) as! GuessResultCollectionViewCell
                cell.configure(resultType: quizHistory.finalResult, guessedResultType: self.guessedResultType, username: self.guessedUser?.username)
                
                return cell
            case .revealedResult(let member, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedResult", for: indexPath) as! RevealedResultCollectionViewCell
                
                cell.configure(withUsername: member.username, withResultType: quizHistory.finalResult, isCurrentUser: member.uid == currentUid)
                
                return cell
            case .unrevealedResult(let member):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnrevealedResult", for: indexPath) as! UnrevealedResultCollectionViewCell
                
                
                cell.configure(withUsername: member.username, isCurrentUser: member.uid == currentUid)
                cell.delegate = self
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
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
        
        let sectionHeaderItemSize =
        NSCollectionLayoutSize(widthDimension:
                .fractionalWidth(1), heightDimension: .estimated(48))
        let sectionHeader =
        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            // Guess Summary
            if sectionIndex == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(265))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 12,
                    trailing: 0
                )
                
                return section
            } else if sectionIndex == 1  {
                // Guess Result
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(425))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            } else {
                // Revealed and Unrevealed Items
                let itemSize =
                NSCollectionLayoutSize(widthDimension:
                        .fractionalWidth(1), heightDimension: .fractionalWidth(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                
                let groupSize =
                NSCollectionLayoutSize(widthDimension:
                        .fractionalWidth(0.75), heightDimension: .estimated(250))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                let availableLayoutWidth =
                environment.container.effectiveContentSize.width
                let groupWidth = availableLayoutWidth * 0.75
                let remainingWidth = availableLayoutWidth - groupWidth
                let halfOfRemainingWidth = remainingWidth / 2.0
                let nonCategorySectionItemInset = CGFloat(4)
                let itemLeadingAndTrailingInset = halfOfRemainingWidth +
                nonCategorySectionItemInset
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: itemLeadingAndTrailingInset, bottom: 20, trailing: itemLeadingAndTrailingInset)
                
                section.interGroupSpacing = 20
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        self.loadingSpinner?.stopAnimating()

        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.guessSummary)
        
        if let currentUser = self.model.currentUser {
            itemsBySection[.guessSummary] = [ViewModel.Item.guessSummary(currentUser: currentUser, quizHistory: userQuizHistory!)]
        }
        
        sectionIDs.append(.currentUserResult)
        itemsBySection[.currentUserResult] = [ViewModel.Item.currentUserResult(member: guessedUser!, quizHistory: userQuizHistory!)]
        
        sectionIDs.append(.membersResults)
        sectionIDs.append(.otherTmatesResults)
        
        print("model.usersss \(model.userMasterTmates)")
        
        for userMasterTmate in model.userMasterTmates {
            
            // if the userMasterTmate has completed the quiz
            if quizHistory!.completedUsers.contains(userMasterTmate.uid) && userMasterTmate.uid != self.guessedUser?.uid {
                
                // If userMasterTmate in the current group
                if let group = group, group.membersIDs.contains(userMasterTmate.uid) {
                    
                    // Ensure the userMasterTmate has a matching quiz history
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                        // if tmate has guessed or is the current user
                        if matchingQuizHistory.membersGuessed.contains(currentUid) || userMasterTmate.uid == currentUid {
                            itemsBySection[.membersResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                        } else {
                            itemsBySection[.membersResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                        }
                    }
                } else {
                    // Ensure the userMasterTmate has a matching quiz history
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
                        // if tmate has guessed or is the current user
                        if matchingQuizHistory.membersGuessed.contains(currentUid) || userMasterTmate.uid == currentUid {
                            itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.revealedResult(member: userMasterTmate, quizHistory: matchingQuizHistory))
                        } else {
                            itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.unrevealedResult(member: userMasterTmate))
                        }
                    }
                }
                
            }
        }
        
        // if the current user has completed the quiz
        if quizHistory!.completedUsers.contains(currentUid), let currentUser = model.currentUser, let matchingQuizHistory = currentUser.userQuizHistory.first(where: { $0.quizID == quiz?.id }) {
            
            if self.group != nil {
                itemsBySection[.membersResults, default: []].append(ViewModel.Item.revealedResult(member: currentUser, quizHistory: matchingQuizHistory))
            } else {
                itemsBySection[.otherTmatesResults, default: []].append(ViewModel.Item.revealedResult(member: currentUser, quizHistory: matchingQuizHistory))
            }
        }
        
        // Sort and update the dataSource
        if let membersResultsItems = itemsBySection[.membersResults] {
            itemsBySection[.membersResults] = membersResultsItems.sorted() // Optional: Sort the items if necessary
        }
        
        if let otherTmatesResultsItems = itemsBySection[.otherTmatesResults] {
            itemsBySection[.otherTmatesResults] = otherTmatesResultsItems.sorted() // Optional: Sort the items if necessary
        }
        
        print("itemsbysiredction \(itemsBySection)")
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    func fetchQuizHistory(completion: @escaping () -> Void) {
        guard let quizID = quiz?.id else {return}
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", isEqualTo: quizID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.loadingSpinner?.stopAnimating()
                completion()
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.quizHistory = try document.data(as: QuizHistory.self)
                        completion()
                    } catch {
                        self.loadingSpinner?.stopAnimating()
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
                self.loadingSpinner?.stopAnimating()
                self.presentErrorAlert(with: "A network error occured!")
            } else {
                
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        self.model.userMasterTmates.append(member)
                    }
                    catch {
                        self.loadingSpinner?.stopAnimating()
                        self.presentErrorAlert(with: "A network error occured!")
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
                
            case .failure(_):
                // Handle the error appropriately
                self.loadingSpinner?.stopAnimating()
                self.presentErrorAlert(with: "A network error occured!")
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
        //        if let item = dataSource.itemIdentifier(for: indexPath) {
        //            switch item {
        //            case .unrevealedResult(let member):
        //                self.performSegue(withIdentifier: "guessToRevealFromGuess", sender: (member))
        //            default:
        //                return
        //            }
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "guessToRevealFromGuess" {
            let guessQuizVC = segue.destination as! GuessQuizViewController
            
            if let senderInfo = sender as? (User) {
                let member = senderInfo
                guessQuizVC.members = self.members
                guessQuizVC.guessedMember = member
                guessQuizVC.userQuizHistory = userQuizHistory
                guessQuizVC.group = self.group
                guessQuizVC.fromResultVC = true
            }
            
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func dismissGuessResultPressed(_ sender: UIBarButtonItem) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
        //        self.dismiss(animated: true)
        //        self.navigationController?.popToRootViewController(animated: true)
        print("dismiss")
        
    }
    
}
