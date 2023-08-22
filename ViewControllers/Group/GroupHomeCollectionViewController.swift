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
    
    enum ViewModel {
        enum Section: Hashable {
            case unrevealedMembers
            case revealedMembers(quizTitle: String)
            case tmateEmojis
        }
        
        enum Item: Hashable, Comparable {
            case unrevealedMember(tmate: User, userQuizHistory: UserQuizHistory)
            case revealedMember(tmate: User, userQuizHistory: UserQuizHistory, isCurrentUser: Bool)
            case tmateEmoji(tmate: User, resultTypes: [ResultType?], isCurrentUser: Bool)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .unrevealedMember(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .revealedMember(let tmate, let userQuizHistory, _):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .tmateEmoji(let tmate, let resultTypes, _):
                    hasher.combine(tmate)
                    hasher.combine(resultTypes)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.unrevealedMember(let lTmate, let lUserQuizHistory), .unrevealedMember(let rTmate, let rUserQuizHistory)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.revealedMember(let lTmate, let lUserQuizHistory, _), .revealedMember(let rTmate, let rUserQuizHistory, _)):
                    return lTmate == rTmate && lUserQuizHistory == rUserQuizHistory
                case (.tmateEmoji(let lTmate, let lResultTypes, _), .tmateEmoji(let rTmate, let rResultTypes, _)):
                    return lTmate == rTmate && lResultTypes == rResultTypes
                default:
                    return false
                }
            }
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.unrevealedMember(_, let lUserQuizHistory), .unrevealedMember(_, let rUserQuizHistory)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.revealedMember(_, let lUserQuizHistory, _), .revealedMember(_, let rUserQuizHistory, _)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.tmateEmoji(let lTmate, let lResultTypes, _), .tmateEmoji(let rTmate, let rResultTypes, _)):
                    if lTmate.points != rTmate.points {
                        return lTmate.points < rTmate.points
                    } else if lResultTypes.count < rResultTypes.count {
                        return lResultTypes.count < rResultTypes.count
                    } else {
                        return lTmate < rTmate
                    }
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
        
        fetchQuizHistory {
            // Fetch the group first, and then fetch the users once the group data is available
            self.fetchGroup { [weak self] group in
                // Update the group variable with the fetched group data
                self?.group = group
                self?.navigationItem.title = self?.group.name
                
                // Fetch users after getting the group data
                self?.fetchUsers()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.hidesBackButton = false
        
        navigationItem.title = group.name
        
        let segmentedControl = UISegmentedControl(items: ["Guesses", "T-mates"])
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        // Add the segmented control to the navigation bar
        navigationItem.titleView = segmentedControl
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

        updateCollectionView()
    }
    
    
    @IBAction func onGroupSettingsClick(_ sender: Any) {
        performSegue(withIdentifier: "showGroupSettings", sender: nil)
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
            case .tmateEmoji(tmate: let tmate, resultTypes: let resultTypes, let isCurrentUser):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TmateEmojis", for: indexPath) as! TmateEmojisCollectionViewCell
                
                
                cell.configure(username: tmate.username, points: tmate.points, resultTypes: resultTypes, isCurrentUser: isCurrentUser)
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .unrevealedMembers:
                sectionHeader.configure(title: "To be Guessed", colorName: "Text")
            case .revealedMembers(let quizTitle):
                
                sectionHeader.configure(title: quizTitle, colorName: "Text")
            case .tmateEmojis:
                sectionHeader.configure(title: "Tmates Emoji Collections", colorName: "Text")
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
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
                
            case .unrevealedMembers:
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
                
                section.contentInsets = sectionEdgeInsets
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                return section
            case .revealedMembers:
                // Revealed Select Member
                let vertSpacing: CGFloat = 10
                
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
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                return section
                
            case .tmateEmojis:
                let vertSpacing: CGFloat = 10
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                
                var group: NSCollectionLayoutGroup!
                
                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
                } else {
                    group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                }
                
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: vertSpacing,
                    trailing: 0
                )
                
                group.interItemSpacing = .fixed(16)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                section.interGroupSpacing = 16
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        switch selectedSegmentIndex {
        case 0:
            sectionIDs.append(.unrevealedMembers)
            
            let uniqueQuizIDs = fetchUniqueQuizIDs()
                                
                for quizID in uniqueQuizIDs {
                    let quizTitle = QuizData.quizzes.first(where: { $0.id == quizID })?.title ?? "Guessed Tmates"
                    sectionIDs.append(.revealedMembers(quizTitle: quizTitle))
                }
                
            
            for (userMasterTmate, userQuizHistories) in model.userQuizHistoriesDict {
                
                for userQuizHistory in userQuizHistories {

                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            let quizTitle = QuizData.quizzes.first(where: { $0.id == matchingQuizHistory.quizID })?.title ?? "Guessed Tmates"
                            
                            itemsBySection[.revealedMembers(quizTitle: quizTitle), default: []].append(ViewModel.Item.revealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory, isCurrentUser: false))
                        } else {
                            itemsBySection[.unrevealedMembers, default: []].append(ViewModel.Item.unrevealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                        }
                    }
                }
            }
            
            if let currentUserQuizHistory = model.currentUser?.userQuizHistory, !currentUserQuizHistory.isEmpty, let currentUser = model.currentUser {
                for userQuizHistory in currentUserQuizHistory {
                    if let matchingQuizHistory = currentUserQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        let quizTitle = QuizData.quizzes.first(where: { $0.id == matchingQuizHistory.quizID })?.title ?? "Guessed Tmates"
                        
                        itemsBySection[.revealedMembers(quizTitle: quizTitle), default: []].append(ViewModel.Item.revealedMember(tmate: currentUser, userQuizHistory: matchingQuizHistory, isCurrentUser: true))
                    }
                }
            }
            
            // Sort the section IDs based on quiz titles
            sectionIDs.sort { (section1, section2) -> Bool in
                switch (section1, section2) {
                case (.unrevealedMembers, _):
                    // .unrevealedMembers should always come first
                    return true
                case let (.revealedMembers(quizTitle1), .revealedMembers(quizTitle2)):
                    // Sort revealed sections based on quiz titles
                    return quizTitle1.localizedCompare(quizTitle2) == .orderedAscending
                default:
                    return false
                }
            }
            
            itemsBySection[.unrevealedMembers] = itemsBySection[.unrevealedMembers]?.sorted(by: >)
            
        case 1:
            sectionIDs.append(.tmateEmojis)
            
            if let currentUser = model.currentUser {
                itemsBySection[.tmateEmojis, default: []].append(ViewModel.Item.tmateEmoji(tmate: currentUser, resultTypes: currentUser.userQuizHistory.map { $0.finalResult }, isCurrentUser: true))
            }
            
            for (userMasterTmate, userQuizHistories) in model.userQuizHistoriesDict {
                var userMasterTmateResultTypes = [ResultType?]()
                
                for userQuizHistory in userQuizHistories {
                    if let quizHistory = model.quizHistories.first(where: { $0.quizID == userQuizHistory.quizID }),
                       quizHistory.completedUsers.contains(userMasterTmate.uid) {
                        
                        userMasterTmateResultTypes.append(userQuizHistory.finalResult)
                    }
                }
                itemsBySection[.tmateEmojis, default: []].append(ViewModel.Item.tmateEmoji(tmate: userMasterTmate, resultTypes: userMasterTmateResultTypes, isCurrentUser: false))
            }
            
            itemsBySection[.tmateEmojis] = itemsBySection[.tmateEmojis]?.sorted(by: >)
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
                self.presentErrorAlert(with: error.localizedDescription)
                completion()
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.model.quizHistories.append(try document.data(as: QuizHistory.self))
                        completion()
                    } catch {
                        self.presentErrorAlert(with: error.localizedDescription)
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
        } else if segue.identifier == "showGroupSettings" {
            let groupSettingsVC = segue.destination as! GroupSettingsViewController
            groupSettingsVC.group = self.group
        } else if segue.identifier == "showTmateProfile" {
            let profileVC = segue.destination as! ProfileCollectionViewController
            
            if let senderInfo = sender as? User {
                let tmate = senderInfo
                
                profileVC.otherUser = tmate
            }
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
                self.presentErrorAlert(with: error.localizedDescription)
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
                        self.presentErrorAlert(with: error.localizedDescription)
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
                self.presentErrorAlert(with: error.localizedDescription)
                completion(nil)
            } else {
                do {
                    let group = try documentSnapshot?.data(as: Group.self)
                    completion(group)
                } catch {
                    self.presentErrorAlert(with: error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    
}
