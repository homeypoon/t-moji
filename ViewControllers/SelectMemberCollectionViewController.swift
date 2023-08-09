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
            case memberSelection(tmate: User)
            case guessedMember(tmate: User, quizHistory: UserQuizHistory)

            func hash(into hasher: inout Hasher) {
                switch self {
                case .memberSelection(let tmate):
                    hasher.combine(tmate)
                case .guessedMember(let tmate, let quizHistory):
                    hasher.combine(tmate)
                    hasher.combine(quizHistory)
                }
            }

            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.memberSelection(let lTmate), .memberSelection(let rTmate)):
                    return lTmate == rTmate
                case (.guessedMember(let lTmate, _), .guessedMember(let rTmate, _)):
                    return lTmate == rTmate
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
            if let masterGroupmatesIDs = self?.currentUser?.masterGroupmatesIDs {
                print("masterGroupmatesIDs\(masterGroupmatesIDs)")
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
            case .memberSelection(let tmate):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuessMemberSelection", for: indexPath) as! GuessMemberSelectionCollectionViewCell
                cell.configure(isGuessed: false, withUsername: tmate.username, withResultType: nil)
                return cell
            case .guessedMember(let tmate, let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuessMemberSelection", for: indexPath) as! GuessMemberSelectionCollectionViewCell
                cell.configure(isGuessed: true, withUsername: tmate.username, withResultType: quizHistory.finalResult)
                print("is guessed member")
                return cell
            }
        }
        
        return dataSource
    }

    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(85))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(85))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section

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
                        itemsBySection[.memberSelections, default: []].append(ViewModel.Item.guessedMember(tmate: userMasterTmate, quizHistory: matchingQuizHistory))
                    } else {
                        itemsBySection[.memberSelections, default: []].append(ViewModel.Item.memberSelection(tmate: userMasterTmate))
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

        print("in memberids \(membersIDs)")

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

}
