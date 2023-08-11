//
//  QuizResultCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "Cell"

class QuizResultCollectionViewController: UICollectionViewController {
    var quiz: Quiz?
    var group: Group?
    var members = [User]() // test delete
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
        
        fetchQuizHistory { [weak self] in
            if let masterGroupmatesIDs = self?.currentUser?.masterGroupmatesIDs, !masterGroupmatesIDs.isEmpty {
                print("masterGroupmatesIDsjkfjsdjfdf\(masterGroupmatesIDs)")
                self!.fetchUserMasterTmates(membersIDs: Array(Set(masterGroupmatesIDs)))
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
            guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
            
            switch item {
            case .currentUserResult(_, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentUserResult", for: indexPath) as! CurrentUserResultCollectionViewCell
                
                cell.configure(withQuizTitle: self.quiz?.title, withResultType: quizHistory.finalResult)
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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(340))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2) // Use count: 2 to have two items per group.
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.currentUserResult)
        itemsBySection[.currentUserResult] = [ViewModel.Item.currentUserResult(member: currentUser!, quizHistory: userQuizHistory!)]
        
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
