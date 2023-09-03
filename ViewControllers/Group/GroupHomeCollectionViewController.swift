//
//  GroupHomeCollectionViewController.swift
//  Groupsona
//
//  Created by Homey Poon on 2023-07-30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class GroupHomeCollectionViewController: UICollectionViewController {
    
    var group: Group!
    @IBOutlet var leaveTeamBarButton: UIBarButtonItem!
    
    enum ViewModel {
        enum Section: Hashable {
            case tmateResults(quizTitle: String)
            case tmateEmojis(tmate: User)
            case noTmateEmojis(tmate: User)
        }
        
        enum Item: Hashable, Comparable {
            case unrevealedMember(tmate: User, userQuizHistory: UserQuizHistory)
            case revealedMember(tmate: User, userQuizHistory: UserQuizHistory, isCurrentUser: Bool)
            case noEmojis(tmate: User)
            case tmateEmoji(tmate: User, resultType: ResultType, isHidden: Bool)
            
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .unrevealedMember(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .revealedMember(let tmate, let userQuizHistory, _):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .tmateEmoji(let tmate, let resultType, _):
                    hasher.combine(tmate)
                    hasher.combine(resultType)
                case .noEmojis(let tmate):
                    hasher.combine(tmate)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.unrevealedMember(let lTmate, let lUserQuizHistory), .unrevealedMember(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.revealedMember(let lTmate, let lUserQuizHistory, _), .revealedMember(let rTmate, let rUserQuizHistory, _)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.tmateEmoji(let lTmate, let lResultType, _), .tmateEmoji(let rTmate, let rResultType, _)):
                    return lResultType == rResultType && lTmate == rTmate
                case (.noEmojis(let lTmate), .noEmojis(let rTmate)):
                    return lTmate == rTmate
                default:
                    return false
                }
            }
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.revealedMember(_, _, _), .unrevealedMember(_, _)):
                    return true // Revealed comes before unrevealed
                case (.unrevealedMember(_, _), .revealedMember(_, _, _)):
                    return false // Unrevealed comes after revealed
                case (.unrevealedMember(_, let lUserQuizHistory), .unrevealedMember(_, let rUserQuizHistory)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.revealedMember(_, let lUserQuizHistory, _), .revealedMember(_, let rUserQuizHistory, _)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.tmateEmoji(_, let lResultType, _), .tmateEmoji(_, let rResultType, _)):
                    return lResultType < rResultType
                default:
                    return false
                }
            }
            
        }
    }
    
    struct Model {
        var tmates = [User]()
        var groupMembers = [User]()
        var userQuizHistoriesDict = [User: [UserQuizHistory]]()
        
        var quizHistories = [QuizHistory]()
        
        var currentUser: User?
        
    }
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var dataSource: DataSourceType!
    var model = Model()
    var selectedSegmentIndex: Int = 0
    var loadingSpinner: UIActivityIndicatorView?
    
    init?(coder: NSCoder, group: Group) {
        self.group = group
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        updateGroupNavigationTitle()
        
        fetchQuizHistory {
            // Fetch the group first, and then fetch the users once the group data is available
            self.fetchGroup { [weak self] group in
                // Update the group variable with the fetched group data
                self?.group = group
                
                self?.updateGroupNavigationTitle()
                
                // Fetch users after getting the group data
                self?.fetchUsers()
            }
        }
        
    }
    
    func updateGroupNavigationTitle() {
        if let emoji = group?.emoji, let name = group?.name {
            navigationItem.title = "\(emoji)  \(name)"
        } else if let name = group?.name {
            navigationItem.title = name
        } else if let emoji = group?.emoji {
            navigationItem.title = emoji
        } else {
            navigationItem.title = ""
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
        
        navigationItem.hidesBackButton = false
        
        navigationItem.title = group.name
        
        let segmentedControl = UISegmentedControl(items: ["Guesses", "T-mates"])
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        // Add the segmented control to the navigation bar
        navigationItem.titleView = segmentedControl
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
        collectionView.register(TmateHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.tmateHeader,  withReuseIdentifier: TmateHeaderCollectionReusableView.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        updateCollectionView()
    }
    
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item {
            case .unrevealedMember(let tmate, let userQuizHistory):
                
                let quizTitle = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })?.title
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnrevealedTmate", for: indexPath) as! UnrevealedTmateCollectionViewCell
                
                cell.configure(withUsername: tmate.username, withQuizTitle: quizTitle, withTimePassed: Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                return cell
            case .revealedMember(let tmate, let userQuizHistory, let isCurrentUser):
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedTmate", for: indexPath) as! RevealedTmateCollectionViewCell
                
                cell.configure(withUsername: tmate.username, withResultType: userQuizHistory.finalResult, withTimePassed: Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime), isCurrentUser: isCurrentUser)
                
                return cell
            case .tmateEmoji(_, let resultType, let isHidden):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TmateEmoji", for: indexPath) as! ProfileEmojiCollectionViewCell
                
                cell.configure(withResultType: resultType, isHidden: isHidden)
                
                return cell
            case .noEmojis(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoEmojis", for: indexPath) as! NoEmojisCollectionViewCell
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            let tmateHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.tmateHeader, withReuseIdentifier: TmateHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! TmateHeaderCollectionReusableView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
                
            case .tmateResults(let quizTitle):
                sectionHeader.configure(title: quizTitle, colorName: "Text")
                return sectionHeader
            case .tmateEmojis(let tmate):
                if let currentUid = Auth.auth().currentUser?.uid {
                    print("tmate.uid == currentUid \(tmate.uid == currentUid)")
                    tmateHeader.configure(username: "\(tmate.username)", points: "\(tmate.points) pts", isCurrentUser: tmate.uid == currentUid)
                }
                
                return tmateHeader
            case .noTmateEmojis(tmate: let tmate):
                if let currentUid = Auth.auth().currentUser?.uid {
                    tmateHeader.configure(username: "\(tmate.username)", points: "\(tmate.points) pts", isCurrentUser: tmate.uid == currentUid)
                }
                return tmateHeader
            }
        }
        
        return dataSource
    }

    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let horzSpacing: CGFloat = 20
            
            let sectionHeaderItemSize =
            NSCollectionLayoutSize(widthDimension:
                    .fractionalWidth(1), heightDimension: .estimated(48))
            let sectionHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
            let tmateHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.tmateHeader, alignment: .top)
            
            // Guess Select Member
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .tmateResults:
                // Tmate Results
                let vertSpacing: CGFloat = 12
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(96))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: vertSpacing,
                    trailing: 0
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                return section
                
            case .tmateEmojis:
                // tmate emojis
                    let vertSpacing: CGFloat = 10
                    
                    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(50), heightDimension: .absolute(50))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(54))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    group.interItemSpacing = .fixed(12)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [tmateHeader]
                    
                    let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: SupplementaryViewKind.sectionBackgroundView)
                    
                    backgroundItem.contentInsets = NSDirectionalEdgeInsets(
                        top: 8,
                        leading: 20,
                        bottom: 16,
                        trailing: 20
                    )
                    
                    section.decorationItems = [backgroundItem]
                    
                    section.interGroupSpacing = 12
                    
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: 12,
                        leading: 40,
                        bottom: 40,
                        trailing: 40
                    )
                    
                    return section
                
            case .noTmateEmojis(tmate: let tmate):
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
                
                section.boundarySupplementaryItems = [tmateHeader]
                
                let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: SupplementaryViewKind.sectionBackgroundView)
                
                backgroundItem.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 20,
                    bottom: 16,
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
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SupplementaryViewKind.sectionBackgroundView)
        return layout
    }
    
    func updateCollectionView() {
        self.loadingSpinner?.stopAnimating()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        switch selectedSegmentIndex {
        case 0:
            
            let uniqueQuizIDs = fetchUniqueQuizIDs()
            
            for quizID in uniqueQuizIDs {
                let quizTitle = QuizData.quizzes.first(where: { $0.id == quizID })?.title ?? "Guessed Tmates"
                sectionIDs.append(.tmateResults(quizTitle: quizTitle))
            }
            
            for (userMasterTmate, userQuizHistories) in model.userQuizHistoriesDict {
                
                for userQuizHistory in userQuizHistories {
                    
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        let quizTitle = QuizData.quizzes.first(where: { $0.id == matchingQuizHistory.quizID })?.title ?? "Tmate Quiz"
                        
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            
                            itemsBySection[.tmateResults(quizTitle: quizTitle), default: []].append(ViewModel.Item.revealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory, isCurrentUser: false))
                        } else {
                            itemsBySection[.tmateResults(quizTitle: quizTitle), default: []].append(ViewModel.Item.unrevealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                        }
                    }
                }
            }
            
            if let currentUserQuizHistory = model.currentUser?.userQuizHistory, !currentUserQuizHistory.isEmpty, let currentUser = model.currentUser {
                for userQuizHistory in currentUserQuizHistory {
                    if let matchingQuizHistory = currentUserQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        let quizTitle = QuizData.quizzes.first(where: { $0.id == matchingQuizHistory.quizID })?.title ?? "Guessed Tmates"
                        
                        itemsBySection[.tmateResults(quizTitle: quizTitle), default: []].append(ViewModel.Item.revealedMember(tmate: currentUser, userQuizHistory: matchingQuizHistory, isCurrentUser: true))
                    }
                }
            }
            
            // Sort the section IDs based on quiz titles
            sectionIDs.sort { (section1, section2) -> Bool in
                switch (section1, section2) {
                case let (.tmateResults(quizTitle1), .tmateResults(quizTitle2)):
                    // Sort revealed sections based on quiz titles
                    return quizTitle1.localizedCompare(quizTitle2) == .orderedAscending
                default:
                    return false
                }
            }
            
            for section in sectionIDs.filter({ if case .tmateResults = $0 { return true } else { return false }}) {
                itemsBySection[section]?.sort()
            }
            
        case 1:
            let uniqueQuizIDs = fetchUniqueQuizIDs()
            
            if let currentUser = model.currentUser {
                let currentUserResultTypes = currentUser.userQuizHistory.map { $0.finalResult }
                sectionIDs.append(.tmateEmojis(tmate: currentUser))
                
                print("currentUserResultTypes \(currentUserResultTypes)")
                for resultType in currentUserResultTypes {
                    itemsBySection[.tmateEmojis(tmate: currentUser), default: []].append(ViewModel.Item.tmateEmoji(tmate: currentUser, resultType: resultType, isHidden: false))
                    print("emoji")
                }
                
                print("current user items emojis \(itemsBySection[.tmateEmojis(tmate: currentUser)])")

                
                if itemsBySection[.tmateEmojis(tmate: currentUser)] == nil {
                    sectionIDs.append(.noTmateEmojis(tmate: currentUser))
                    itemsBySection[.noTmateEmojis(tmate: currentUser)] = [ViewModel.Item.noEmojis(tmate: currentUser)]
                }
                
                if let emojiSection = itemsBySection[.tmateEmojis(tmate: currentUser)], emojiSection.isEmpty {
                    sectionIDs.append(.noTmateEmojis(tmate: currentUser))
                    itemsBySection[.noTmateEmojis(tmate: currentUser)] = [ViewModel.Item.noEmojis(tmate: currentUser)]
                }
            }
            
            for (userMasterTmate, userQuizHistories) in model.userQuizHistoriesDict {
                sectionIDs.append(.tmateEmojis(tmate: userMasterTmate))
                                
                for userQuizHistory in userQuizHistories {
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            
                            itemsBySection[.tmateEmojis(tmate: userMasterTmate), default: []].append(ViewModel.Item.tmateEmoji(tmate: userMasterTmate, resultType: userQuizHistory.finalResult, isHidden: false))
                            print("not guessed")
                        } else {
                            itemsBySection[.tmateEmojis(tmate: userMasterTmate), default: []].append(ViewModel.Item.tmateEmoji(tmate: userMasterTmate, resultType: userQuizHistory.finalResult, isHidden: true))
                            print("guessed")
                        }
                    }
                }
                
                if itemsBySection[.tmateEmojis(tmate: userMasterTmate)] == nil {
                    sectionIDs.append(.noTmateEmojis(tmate: userMasterTmate))
                    itemsBySection[.noTmateEmojis(tmate: userMasterTmate)] = [ViewModel.Item.noEmojis(tmate: userMasterTmate)]
                }
                
                if let emojiSection = itemsBySection[.tmateEmojis(tmate: userMasterTmate)], emojiSection.isEmpty {
                    sectionIDs.append(.noTmateEmojis(tmate: userMasterTmate))
                    itemsBySection[.noTmateEmojis(tmate: userMasterTmate)] = [ViewModel.Item.noEmojis(tmate: userMasterTmate)]
                }
            }
            
            // Sort the section IDs based on quiz titles
            sectionIDs.sort { (section1, section2) -> Bool in
                switch (section1, section2) {
                case let (.tmateEmojis(lTmate), .tmateEmojis(rTmate)):
                    if lTmate.points != rTmate.points {
                        return lTmate.points > rTmate.points
                    } else {
                        return lTmate < rTmate
                    }
                case (.tmateEmojis, .noTmateEmojis):
                    return true 
                default:
                    return false
                }
            }
            
            for section in sectionIDs.filter({ if case .tmateResults = $0 { return true } else { return false }}) {
                itemsBySection[section]?.sort()
            }
            
            for section in sectionIDs.filter({ if case .tmateResults = $0 { return true } else { return false }}) {
                itemsBySection[section] = itemsBySection[section]?.sorted(by: >)
            }
            
        default:
            break
        }
            
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    func fetchQuizHistory(completion: @escaping () -> Void) {
        self.model.quizHistories.removeAll()
        
        FirestoreService.shared.db.collection("quizHistories").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.loadingSpinner?.stopAnimating()
                completion()
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.model.quizHistories.append(try document.data(as: QuizHistory.self))
                        completion()
                    } catch {
                        self.loadingSpinner?.stopAnimating()
                        completion()
                    }
                }
            }
        }
    }
    
    func fetchUniqueQuizIDs() -> [Int] {
        var uniqueQuizIDs = Set<Int>()
        
        for userQuizHistory in model.currentUser?.userQuizHistory ?? [] {
            uniqueQuizIDs.insert(userQuizHistory.quizID)
        }
        
        for (_, userQuizHistories) in model.userQuizHistoriesDict {
            for userQuizHistory in userQuizHistories {
                uniqueQuizIDs.insert(userQuizHistory.quizID)
            }
        }
        
        return Array(uniqueQuizIDs)
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
            case .unrevealedMember(let tmate, let userQuizHistory):
                self.performSegue(withIdentifier: "showGuessQuiz", sender: (tmate, userQuizHistory))
            case .revealedMember(let tmate, let userQuizHistory, let isCurrentUser):
                
                if isCurrentUser {
                    self.performSegue(withIdentifier: "showRevealedResults", sender: (tmate, userQuizHistory, isCurrentUser))
                } else {
                    self.performSegue(withIdentifier: "showRevealedResults", sender: (tmate, userQuizHistory, isCurrentUser))
                }
                print("tmatee \(tmate)")
                
            case .tmateEmoji(tmate: let tmate, _, _):
                self.performSegue(withIdentifier: "showTmateProfile", sender: tmate)
            case .noEmojis(tmate: let tmate):
                self.performSegue(withIdentifier: "showTmateProfile", sender: tmate)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showGuessQuiz" {
            
            let guessQuizVC = segue.destination as! GuessQuizViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let tmate = senderInfo.0
                let userQuizHistory = senderInfo.1
                
                guessQuizVC.guessedMember = tmate
                guessQuizVC.userQuizHistory = userQuizHistory
                guessQuizVC.group = group
            }
            
        } else if segue.identifier == "showRevealedResults" {
            let navController = segue.destination as! UINavigationController
            let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory, Bool) {
                let tmate = senderInfo.0
                let userQuizHistory = senderInfo.1
                let isCurrentUser = senderInfo.2
                
                print("tmatee2 \(tmate)")
                
                quizResultVC.quiz = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })
                quizResultVC.resultUser = tmate
                quizResultVC.userQuizHistory = userQuizHistory
                quizResultVC.group = group
                
                quizResultVC.quizResultType = isCurrentUser ? .checkOwnResult : .checkOtherResult
            }
        } else if segue.identifier == "showTmateProfile" {
            let profileVC = segue.destination as! ProfileCollectionViewController
            
            if let senderInfo = sender as? User {
                let tmate = senderInfo
                
                profileVC.otherUser = tmate
            }
        } else if segue.identifier == "showAddTmates" {
            
            let addUsersVC = segue.destination as! AddUsersCollectionViewController
            
            addUsersVC.group = group
            
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
            addUsersVC.membersIDs = group.membersIDs
        }
    }
    
    
    // Get all users in the group membersIDs array
    private func fetchUsers() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard var membersIDs = group?.membersIDs, !membersIDs.isEmpty
        else { return }
        
        membersIDs.append(currentUid)
        
        self.model.groupMembers.removeAll()
        self.model.tmates.removeAll()
        self.model.userQuizHistoriesDict.removeAll()
        
        FirestoreService.shared.db.collection("users").whereField("uid", in: membersIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.loadingSpinner?.stopAnimating()
                self.presentErrorAlert(with: "An error occured!")
            } else {
                
                for document in querySnapshot!.documents {
                    do {
                        let member = try document.data(as: User.self)
                        
                        self.model.groupMembers.append(member)
                        
                        if member.uid != currentUid {
                            self.model.tmates.append(member)
                            
                            let memberQuizHistory = member.userQuizHistory
                            
                            var quizHistory = [UserQuizHistory]()
                            
                            for memQuizHistory in memberQuizHistory {
                                quizHistory.append(memQuizHistory)
                            }
                            
                            self.model.userQuizHistoriesDict[member] = quizHistory
                        } else {
                            self.model.currentUser = member
                        }
                    }
                    catch {
                        self.loadingSpinner?.stopAnimating()
                        self.presentErrorAlert(with: "An error occured!")
                    }
                }
                self.updateCollectionView()
            }
        }
    }
    
    private func fetchGroup(completion: @escaping (Group?) -> Void) {
        guard let groupID = group?.id else {
            completion(nil)
            return
        }
        
        FirestoreService.shared.db.collection("groups").document(groupID).getDocument { (documentSnapshot, error) in
            if let error = error {
                self.loadingSpinner?.stopAnimating()
                completion(nil)
            } else {
                do {
                    let group = try documentSnapshot?.data(as: Group.self)
                    completion(group)
                } catch {
                    self.loadingSpinner?.stopAnimating()
                    completion(nil)
                }
            }
        }
    }
    
    @IBAction func leaveGroupBarButtonClicked(_ sender: UIBarButtonItem) {
        
        presentLeaveGroupAlert()
    }
    
    func presentLeaveGroupAlert() {
        let alert = UIAlertController(title: "Leave T--m Confirmation", message: "Are you sure you want to leave \(group.name)?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        let leaveGroupAction = UIAlertAction(title: "Leave T--m", style: .destructive, handler: {_ in
            self.performSegue(withIdentifier: "unwindToHomeAndLeaveGroup", sender: nil)
        })
        alert.addAction(leaveGroupAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToGroupHome(segue: UIStoryboardSegue) {
    }
}
