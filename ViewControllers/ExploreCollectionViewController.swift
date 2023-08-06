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
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        fetchUser(userID: userID) { user in
            self.model.user = user
            self.fetchQuizHistories()
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
        
        // Create a dictionary to associate quiz histories with quizzes
        var quizHistoryDictionary: [Int: QuizHistory] = [:]
        
        // Assuming you have fetched quizHistories from Firestore and stored them in an array called quizHistories
        for quizHistory in model.quizHistories {
            quizHistoryDictionary[quizHistory.quizID] = quizHistory
        }
        
        var quizHistoryTuples: [(quiz: Quiz, quizHistory: QuizHistory?, completeState: Bool, currentUserResultType: ResultType?, takenByText: String)] = []
        let dispatchGroup = DispatchGroup() // Create a DispatchGroup
        
        for quiz in QuizData.quizzes {
            var takenByText = TakenByText.noTmates
            var completeState = false
            var currentUserResultType: ResultType? = nil
            var currentQuizHistory: QuizHistory? = nil
            
            if let quizHistory = quizHistoryDictionary[quiz.id] {
                currentQuizHistory = quizHistory
                
                let completedUsersCount = quizHistory.completedUsers.count
                
                guard let user = model.user else { return }
                
                print("mastergroupmatesid\(user.masterGroupmatesIDs)")
                print(quizHistory.completedUsers)
                let completedMemberCount = quizHistory.completedUsers.filter { Set(user.masterGroupmatesIDs).contains($0) }.count
                
                print("comple\(completedMemberCount)")
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let userHasCompletedQuiz = quizHistory.completedUsers.contains(uid)
                
                if userHasCompletedQuiz {
                    completeState = true
                    currentUserResultType = user.quizHistory.first(where: { $0.quizID == quiz.id })?.finalResult
                }
                
                switch completedMemberCount {
                case 1:
                    let userID = quizHistory.completedUsers[0]
                    dispatchGroup.enter()
                    fetchUser(userID: userID) { user in
                        takenByText = "Taken by \(user.username)"
                        print("takenBY text \(takenByText)")
                        dispatchGroup.leave()
                    }
                default:
                    let firstUserID = quizHistory.completedUsers[0]
                    let secondUserID = quizHistory.completedUsers[1]
                    dispatchGroup.enter()
                    self.fetchUser(userID: firstUserID) { firstUser in
                        self.fetchUser(userID: secondUserID) { secondUser in
                            if completedUsersCount == 2 {
                                takenByText = "Taken by \(firstUser.username) and \(secondUser.username)"
                            } else if completedUsersCount == 3 {
                                takenByText = "Taken by \(firstUser.username), \(secondUser.username), and 1 other"
                            } else {
                                takenByText = "Taken by \(firstUser.username), \(secondUser.username), and \(completedUsersCount - 2) others"
                            }
                            print("append others takenBY text \(takenByText)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
            }
            
            dispatchGroup.notify(queue: .main) {
                quizHistoryTuples.append((quiz, currentQuizHistory, completeState, currentUserResultType, takenByText))
                print("takenBY text append \(takenByText)")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // This block will be executed after all asynchronous calls have completed
            print("updateCollectionViewWithNewData \(quizHistoryTuples)")
            self.updateCollectionViewWithNewData(quizHistoryTuples)
        }
    }
    
    func updateCollectionViewWithNewData(_ quizHistoryTuples: [(quiz: Quiz, quizHistory: QuizHistory?, completeState: Bool, currentUserResultType: ResultType?, takenByText: String)]) {
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        for (quiz, quizHistory, completeState, currentUserResultType, takenByText) in quizHistoryTuples {
            let item = ViewModel.Item.quiz(
                quiz: quiz,
                quizHistory: quizHistory,
                completeState: completeState,
                currentUserResultType: currentUserResultType,
                takenByText: takenByText
            )
            print("item \(item)")
            itemsBySection[.quizzes, default: []].append(item)
        }
        
        dataSource.applySnapshotUsing(sectionIds: [.quizzes], itemsBySection: itemsBySection)
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchUser(userID: String, completion: @escaping (User) -> Void) {
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
    
    // Get groups whose membersIDs contains the current user's id
    private func fetchQuizHistories() {
        
        FirestoreService.shared.db.collection("quizHistories").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                self.model.quizHistories.removeAll()
                
                for document in querySnapshot!.documents {
                    do {
                        let quizHistory = try document.data(as: QuizHistory.self)
                        
                        self.model.quizHistories.append(quizHistory)
                    }
                    catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                self.updateCollectionView()
            }
        }
    }
    
    func addQuizHistory() {
        let quizID = 1
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let collectionRef = FirestoreService.shared.db.collection("quizHistories")
        
        let quizHistory = QuizHistory(quizID: QuizData.quizzes[1].id, completedUsers: [userId, userId, userId, userId])
        
        do {
            try collectionRef.document(String(quizID)).setData(from: quizHistory)
        }
        catch {
            presentErrorAlert(with: error.localizedDescription)
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
