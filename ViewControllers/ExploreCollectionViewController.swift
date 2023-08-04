//
//  ExploreCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ExploreCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case quizzes
        }
        
        enum Item: Hashable {
            case quiz(quiz: Quiz, completeStateText: String, currentUserResultType: ResultType, takenByText: String)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .quiz(let quiz, _, _, _):
                    hasher.combine(quiz)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.quiz(let lQuiz, _, _, _), .quiz(let rQuiz, _, _, _)):
                    return lQuiz == rQuiz
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var groups = [Group]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroups()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    // Get groups whose membersIDs contains the current user's id
    private func fetchGroups() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirestoreService.shared.db.collection("groups").whereField("membersIDs", arrayContains: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                self.model.groups.removeAll()
                
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: Group.self)
                        
                        self.model.groups.append(group)
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
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .quiz(let quiz, let completeStateText, let currentUserResultType, let takenByText):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreQuizCell", for: indexPath) as! ExploreQuizCollectionViewCell
                
                cell.configure(quiz: quiz, completeStateText: completeStateText, currentUserResultType: currentUserResultType, takenByText: takenByText)
                
                return cell
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        
        sectionIDs.append(.quizzes)
        var quizItems = [ViewModel.Item]()
        
        var itemsBySection = QuizData.quizzes.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, quiz in
            
            partial[.quizzes, default: []].append(ViewModel.Item.quiz(quiz: quiz, completeStateText: "done", currentUserResultType: .apple, takenByText: "s"))
        }
                
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
    }

    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
