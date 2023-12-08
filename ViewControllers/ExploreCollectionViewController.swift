//
//  ExploreCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import GoogleMobileAds

class ExploreCollectionViewController: UICollectionViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case quizzes
            case allQuizzesCompleted
        }
        
        enum Item: Hashable {
            
            case quiz(quiz: Quiz, quizHistory: QuizHistory?, completeState: Bool, currentUserResultType: ResultType?, takenByText: String)
            case adInlineBanner(uuid: UUID)
            case quizzesCompleted
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .quiz(let quiz, _, _, _, _):
                    hasher.combine(quiz)
                case .adInlineBanner(let uuid):
                    hasher.combine(uuid)
                case .quizzesCompleted:
                    hasher.combine("quizzes completed")
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.quiz(let lQuiz, _, _, _, _), .quiz(let rQuiz, _, _, _, _)):
                    return lQuiz == rQuiz
                case (.adInlineBanner(let lUUID), .adInlineBanner(let rUUID)):
                    return lUUID == rUUID
                case (.quizzesCompleted, .quizzesCompleted):
                    return true
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
    
    let exploreItemSize: CGFloat = 160.0
    
    var dataSource: DataSourceType!
    var model = Model()
    var selectedSegmentIndex: Int = 0
    var loadingSpinner: UIActivityIndicatorView?
    
    
    var searchController: UISearchController!
    
    func setUpSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        // Customize search bar appearance
        searchController.searchBar.placeholder = "Search Quizzes"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            // No search text, handle as needed
            return
        }
        
        if searchText.isEmpty {
            // No search text, display all quizzes
            updateCollectionView()
        } else {
            // Filter your data based on the search text
            let filteredQuizzes = QuizData.quizzes.filter { quiz in
                return quiz.title.lowercased().contains(searchText) // Adjust the property you want to search by
            }
            
            // Update the collection view with filtered results
            updateCollectionView(filteredQuizzes: filteredQuizzes)
        }
    }
    
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
        // Create and configure the loading spinner
        
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
        
        setUpSearchController()
        
        let segmentedControl = UISegmentedControl(items: ["All", "Not Taken"])
        
//        addQuizHistories()
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        navigationItem.titleView = segmentedControl
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        loadingSpinner?.startAnimating()
        
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        print("in segmented value change")
        
        updateCollectionView()
    }
    
    // Reset quiz histories
    func addQuizHistories() {
        
        for quiz in QuizData.quizzes {
            
            let collectionRef = FirestoreService.shared.db.collection("quizHistories")
            
            do {
                
                try collectionRef.document("\(quiz.id)").setData(from:  QuizHistory(quizID: quiz.id))
            }
            catch {
                dismiss(animated: false, completion: nil)
                presentErrorAlert(with: error.localizedDescription)
            }
        }
        
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .quiz(let quiz, _, let completeState, let currentUserResultType, let takenByText):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreQuizCell", for: indexPath) as! ExploreQuizCollectionViewCell
                
                cell.configure(quiz: quiz, completeState: completeState, currentUserResultType: currentUserResultType, takenByText: takenByText)
                
                return cell
                
            case .adInlineBanner(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                "ExploreInlineAd", for: indexPath)
                
                let adSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(self.exploreItemSize, self.exploreItemSize)
                let adBannerView = GADBannerView(adSize: adSize)
//                adBannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111" // test
               
                adBannerView.adUnitID = "ca-app-pub-2315105541829350/5326383257"
                adBannerView.rootViewController = self
                
                
                // Step 3: Load an ad.
                let request = GADRequest()
                adBannerView.load(request)
                // TODO: Insert banner view in table view or scroll view, etc.
                
                cell.contentView.addSubview(adBannerView)
                adBannerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    adBannerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    adBannerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    adBannerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    adBannerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
                return cell
            case .quizzesCompleted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompletedQuizzes", for: indexPath) as! CompletedQuizzesCollectionViewCell
                cell.configure()
                return cell
            }
            
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let vertSpacing: CGFloat = 10
        let horzSpacing: CGFloat = 12
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            if sectionIndex == 0 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.exploreItemSize))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: horzSpacing, bottom: 20, trailing: horzSpacing)
                
                section.interGroupSpacing = 16
                
                return section
            } else {
                // All quizzes taken
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                } else {
                    group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                }
                
                let section = NSCollectionLayoutSection(group: group)

                                    
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: horzSpacing, bottom: 20, trailing: horzSpacing)
                
                return section
            }
        }
    }
    
    func updateCollectionView(filteredQuizzes: [Quiz]? = nil) {
        loadingSpinner?.stopAnimating()
        print("updating colleciton view explore")
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.quizzes)
        
        var quizzes: [Quiz]!
        
        if let filteredQuizzes {
            quizzes = filteredQuizzes
            print("filtered")
        } else {
            quizzes = QuizData.quizzes
        }
                
        var itemIndex = 0
        
        for quiz in quizzes {
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
    
            // Insert an AdMob banner item every 4 quiz items
            if itemIndex % 4 == 3 {
                itemsBySection[.quizzes, default: []].append(ViewModel.Item.adInlineBanner(uuid: UUID()))
            }
            
            if let user = model.user, selectedSegmentIndex == 1 {
                //            print("")
                if completeState == false {
                    itemsBySection[.quizzes, default: []].append(item)
                    itemIndex += 1
                }
            } else {
                itemsBySection[.quizzes, default: []].append(item)
                itemIndex += 1
            }
        }
        
        
        if itemsBySection[.quizzes] == nil  {
            
            sectionIDs.append(.allQuizzesCompleted)
            itemsBySection[.allQuizzesCompleted] = [ViewModel.Item.quizzesCompleted]
        } else if let quizzes = itemsBySection[.quizzes], quizzes.isEmpty {
            sectionIDs.append(.allQuizzesCompleted)
            itemsBySection[.allQuizzesCompleted] = [ViewModel.Item.quizzesCompleted]
        }
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
            case .adInlineBanner:
                break
            case .quizzesCompleted:
                break
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

extension ExploreCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        UIView.animate(withDuration: 0.2) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
            cell?.contentView.backgroundColor = UIColor(named: "cellHighlight")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.transform = .identity
            cell?.contentView.backgroundColor = UIColor.white
        }
    }
}

