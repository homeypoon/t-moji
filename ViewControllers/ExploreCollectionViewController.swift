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
            case quiz(quiz: Quiz, quizHistory: QuizHistory?, completeState: Bool, currentUserResultType: ResultType?, takenByText: String)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .quiz(let quiz, _, _, _, _):
                    hasher.combine(quiz)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.quiz(let lQuiz, _, _, _, _), .quiz(let rQuiz, _, _, _, _)):
                    return lQuiz == rQuiz
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var user: User?
        var quizHistories = [QuizHistory]()
        var completedTmates = [Int: [User]]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        fetchCurrentUser(userID: userID) { user in
            self.model.user = user
            
            self.fetchQuizHistories(currentUser: user) {
                self.fetchTmates()
            }
        }
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
            case .quiz(let quiz, _, let completeState, let currentUserResultType, let takenByText):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreQuizCell", for: indexPath) as! ExploreQuizCollectionViewCell
                
                cell.configure(quiz: quiz, completeState: completeState, currentUserResultType: currentUserResultType, takenByText: takenByText)
                
                return cell
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        let vertSpacing: CGFloat = 10
        let horzSpacing: CGFloat = 12
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: vertSpacing,
            trailing: 0
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: horzSpacing, bottom: 0, trailing: horzSpacing)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateCollectionView() {
        print("updating colleciton view explore")
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.quizzes)
        
        for quiz in QuizData.quizzes {
            //            var takenByText = TakenByText.noTmates
            var takenByText = ""
            var completeState = false
            var currentUserResultType: ResultType? = nil
            
            if let quizHistory = model.quizHistories.first(where: { $0.quizID == quiz.id }) {
                
                guard let user = model.user else {
                    continue
                }
                print("quiz hish \(quizHistory)")
                
                print("compleuser\(quizHistory.completedUsers)")
                let userHasCompletedQuiz = quizHistory.completedUsers.contains(user.uid)
                
                print("userHasCompletedQuiza \(userHasCompletedQuiz)")
                
                if userHasCompletedQuiz {
                    completeState = true
                    currentUserResultType = user.userQuizHistory.first(where: { $0.quizID == quiz.id })?.finalResult
                }
                
                
                if let completedTmates = model.completedTmates[quiz.id]?.filter({ $0.uid != user.uid }), !completedTmates.isEmpty {
                    
                    switch completedTmates.count {
                    case 0:
                        takenByText = TakenByText.noTmates
                    case 1:
                        takenByText = "Taken by \(completedTmates[0].username)"
                        print("takenBY text \(takenByText)")
                        
                    default:
                        if completedTmates.count == 2 {
                            takenByText = "Taken by \(completedTmates[0].username) and \(completedTmates[1].username)"
                        } else if completedTmates.count == 3 {
                            takenByText = "Taken by \(completedTmates[0].username), \(completedTmates[1].username), and 1 other"
                        } else {
                            takenByText = "Taken by \(completedTmates[0].username), \(completedTmates[1].username), and \(completedTmates.count - 2) others"
                            
                            print("append others takenBY text \(takenByText)")
                        }
                    }
                } else {
                    takenByText = TakenByText.noTmates
                }
            }
            
            let item = ViewModel.Item.quiz(
                quiz: quiz,
                quizHistory: model.quizHistories.first(where: { $0.quizID == quiz.id }),
                completeState: completeState,
                currentUserResultType: currentUserResultType,
                takenByText: takenByText
            )
            
            itemsBySection[.quizzes, default: []].append(item)
        }
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchCurrentUser(userID: String, completion: @escaping (User) -> Void) {
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                completion(user)
                
            case .failure(let error):
                // Handle the error appropriately
                self.presentErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
    private func fetchTmates() {
        self.model.completedTmates.removeAll()
        
        let fetchTmatesDispatchGroup = DispatchGroup()
        
        print("called")
        
        for quizHistory in self.model.quizHistories {
            fetchTmatesDispatchGroup.enter()
            print("entered")
            
            
            var membersIDs = [String]()
            
            if quizHistory.completedUsers.count == 1 {
                membersIDs = [quizHistory.completedUsers[0]]
            } else if quizHistory.completedUsers.count >= 2 {
                membersIDs = [quizHistory.completedUsers[0], quizHistory.completedUsers[1]]
            }
            
            if !membersIDs.isEmpty {
                
                FirestoreService.shared.db.collection("users").whereField("uid", in: quizHistory.completedUsers).getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        self.presentErrorAlert(with: error.localizedDescription)
                        fetchTmatesDispatchGroup.leave()
                    } else {
                        for document in querySnapshot!.documents {
                            do {
                                let tmate = try document.data(as: User.self)
                                self.model.completedTmates[quizHistory.quizID] = (self.model.completedTmates[quizHistory.quizID] ?? []) + [tmate]
                            }
                            catch {
                                self.presentErrorAlert(with: error.localizedDescription)
                            }
                        }
                        fetchTmatesDispatchGroup.leave()
                    }
                }
            } else {
                fetchTmatesDispatchGroup.leave()
            }
        }
        fetchTmatesDispatchGroup.notify(queue: .main) {
            self.updateCollectionView()
            print("calling colleciton view update")
        }
        
    }
    
    // Get groups whose membersIDs contains the current user's id
    func fetchQuizHistories(currentUser: User, completion: @escaping () -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        FirestoreService.shared.db.collection("quizHistories").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
                completion()
            } else {
                self.model.quizHistories.removeAll()
                
                for document in querySnapshot!.documents {
                    do {
                        var quizHistory = try document.data(as: QuizHistory.self)
                        
                        quizHistory.completedUsers = quizHistory.completedUsers.filter { userID in
                            currentUser.masterGroupmatesIDs.contains(userID) || userID == currentUid }
                        print("filtered")
                        print("mastergorupmatedsid \(currentUser.masterGroupmatesIDs)")
                        print("quizHistory \(quizHistory)")
                        self.model.quizHistories.append(quizHistory)
                        
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                
                completion()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .quiz(let quiz, let quizHistory, let completeState, let currentUserResultType, let takenByText):
                self.performSegue(withIdentifier: "showQuizDetail", sender: (quiz, quizHistory, completeState, currentUserResultType, takenByText))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showQuizDetail" {
            let quizDetailVC = segue.destination as! QuizDetailViewController
            
            if let senderInfo = sender as? (Quiz, QuizHistory?, Bool, ResultType?, String) {
                let quiz = senderInfo.0
                let quizHistory = senderInfo.1
                let completeState = senderInfo.2
                let currentUserResultType = senderInfo.3
                let takenByText = senderInfo.4
                
                quizDetailVC.quiz = quiz
                quizDetailVC.currentUser = model.user
                quizDetailVC.quizHistory = quizHistory
                quizDetailVC.quizCompleteState = completeState
                quizDetailVC.currentUserResultType = currentUserResultType
                quizDetailVC.takenByText = takenByText
            }
        }
    }
}
