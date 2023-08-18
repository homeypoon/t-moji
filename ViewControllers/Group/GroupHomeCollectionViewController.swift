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
        enum Section: Hashable, Comparable {
            case unrevealedMembers
            case revealedMembers
            case tmateEmojis
        }
        enum Item: Hashable, Comparable {
            case unrevealedMember(tmate: User, userQuizHistory: UserQuizHistory)
            case revealedMember(tmate: User, userQuizHistory: UserQuizHistory)
            case tmateEmoji(tmate: User, resultTypes: [ResultType?], isCurrentUser: Bool)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .unrevealedMember(let tmate, let userQuizHistory):
                    hasher.combine(tmate)
                    hasher.combine(userQuizHistory)
                case .revealedMember(let tmate, let userQuizHistory):
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
                case (.revealedMember(let lTmate, let lUserQuizHistory), .revealedMember(let rTmate, let rUserQuizHistory)):
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
                case (.revealedMember(_, let lUserQuizHistory), .revealedMember(_, let rUserQuizHistory)):
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
                
                // Fetch users after getting the group data
                self?.fetchUsers()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 2000, height: 40)
        button.setTitle(group?.name, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside)
        navigationItem.titleView = button
        
        navigationItem.hidesBackButton = true
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @objc func clickOnButton() {
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
            case .revealedMember(let tmate, let userQuizHistory):
                let quizTitle = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })?.title
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RevealedTmate", for: indexPath) as! RevealedTmateCollectionViewCell
                
                cell.configure(withUsername: tmate.username, withResultType: userQuizHistory.finalResult, withQuizTitle: quizTitle, withTimePassed: Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                
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
            case .revealedMembers:
                sectionHeader.configure(title: "Guessed T-mates", colorName: "Text")
            case .tmateEmojis:
                sectionHeader.configure(title: "Tmates Emoji Collection", colorName: "Text")
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
                let vertSpacing: CGFloat = 10
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(96))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = sectionEdgeInsets
                
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
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = sectionEdgeInsets
                
                return section
                
            case .tmateEmojis:
                let vertSpacing: CGFloat = 10
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: horzSpacing,
                    bottom: vertSpacing,
                    trailing: horzSpacing
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = sectionEdgeInsets
                
                return section
            }
        }
    }
    
    func updateCollectionView() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.unrevealedMembers)
        sectionIDs.append(.revealedMembers)
        sectionIDs.append(.tmateEmojis)
        
        
        for (userMasterTmate, userQuizHistories) in model.userQuizHistoriesDict {
            var userMasterTmateResultTypes = [ResultType?]()
            
            for userQuizHistory in userQuizHistories {
                if let quizHistory = model.quizHistories.first(where: { $0.quizID == userQuizHistory.quizID }),
                   quizHistory.completedUsers.contains(userMasterTmate.uid) {
                    
                    if let matchingQuizHistory = userMasterTmate.userQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            itemsBySection[.revealedMembers, default: []].append(ViewModel.Item.revealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                            userMasterTmateResultTypes.append(userQuizHistory.finalResult)
                            
                        } else {
                            itemsBySection[.unrevealedMembers, default: []].append(ViewModel.Item.unrevealedMember(tmate: userMasterTmate, userQuizHistory: matchingQuizHistory))
                            userMasterTmateResultTypes.append(nil)
                        }
                    }
                }
            }
            itemsBySection[.tmateEmojis, default: []].append(ViewModel.Item.tmateEmoji(tmate: userMasterTmate, resultTypes: userMasterTmateResultTypes, isCurrentUser: false))
        }
        
        if let currentUser = model.currentUser {
            itemsBySection[.tmateEmojis, default: []].append(ViewModel.Item.tmateEmoji(tmate: currentUser, resultTypes: currentUser.userQuizHistory.map { $0.finalResult }, isCurrentUser: true))
        }
        
        itemsBySection[.unrevealedMembers] = itemsBySection[.unrevealedMembers]?.sorted()
        itemsBySection[.revealedMembers] = itemsBySection[.revealedMembers]?.sorted()
        itemsBySection[.tmateEmojis] = itemsBySection[.tmateEmojis]?.sorted()
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
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
            case .revealedMember(let tmate, let userQuizHistory):
                self.performSegue(withIdentifier: "showRevealedResults", sender: (tmate, userQuizHistory))
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
            let quizResultVC = segue.destination as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (User, UserQuizHistory) {
                let tmate = senderInfo.0
                let userQuizHistory = senderInfo.1
                
                print("tmatee2 \(tmate)")
                
                quizResultVC.quiz = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })
                quizResultVC.resultUser = tmate
                quizResultVC.userQuizHistory = userQuizHistory
                quizResultVC.group = group
                quizResultVC.quizResultType = .checkOtherResult
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
