//
//  ProfileCollectionViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private let reuseIdentifier = "Cell"

class SectionBackgroundView: UICollectionReusableView {
    
    override func didMoveToSuperview() {
//        translatesAutoresizingMaskIntoConstraints = false
        self.applyRoundedCornerAndShadow(reusableViewType: .tmatesEmojiCollection)
//        clipsToBounds = true
//
//        backgroundColor = .white
//        layer.cornerRadius = 15
//
//        layer.borderWidth = 3
//        layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
//        layer.masksToBounds = true
    }
}


class ProfileCollectionViewController: UICollectionViewController {
    @IBOutlet var settingsBarButton: UIBarButtonItem!
    @IBOutlet var editProfileBarButton: UIBarButtonItem!
    
    var user: User?
    var otherUser: User?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case profileInfo
            case userEmojis
            case userQuizHistory
        }
        enum Item: Hashable {
            case profile(user: User)
            case emoji(resultType: ResultType, isHidden: Bool)
            case noEmojis
            case userQuizHistory(userQuizHistory: UserQuizHistory)
            case hiddenUserQuizHistory(userQuizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .profile(let user):
                    hasher.combine(user)
                case .emoji(let resultType, _):
                    hasher.combine(resultType)
                case .userQuizHistory(let quizHistory):
                    hasher.combine(quizHistory)
                case .hiddenUserQuizHistory(let quizHistory):
                    hasher.combine(quizHistory)
                case .noEmojis:
                    hasher.combine("No Emojis Yet")
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.profile(let lUser), .profile(let rUser)):
                    return lUser == rUser
                case (.emoji(let lEmoji, _), .emoji(let rEmoji, _)):
                    return lEmoji == rEmoji
                case (.userQuizHistory(let lQuizHistory), .userQuizHistory(let rQuizHistory)):
                    return lQuizHistory == rQuizHistory
                case (.hiddenUserQuizHistory(let lQuizHistory), .hiddenUserQuizHistory(let rQuizHistory)):
                    return lQuizHistory == rQuizHistory
                case (.noEmojis, .noEmojis):
                    return true
                default:
                    return false
                }
            }
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.hiddenUserQuizHistory(let lUserQuizHistory), .hiddenUserQuizHistory( let rUserQuizHistory)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.userQuizHistory(let lUserQuizHistory), .userQuizHistory(let rUserQuizHistory)):
                    return lUserQuizHistory.userCompleteTime < rUserQuizHistory.userCompleteTime
                case (.hiddenUserQuizHistory(_), .userQuizHistory(_)):
                    return true
                case (.userQuizHistory(_), .hiddenUserQuizHistory(_)):
                    return false
                default:
                    return false
                }
            }
        }
        
    }
    
    struct Model {
        var quizHistories = [QuizHistory]()
    }
    
    func getResultTypes(userQuizHistories: [UserQuizHistory])-> [ResultType] {
        return userQuizHistories.map { $0.finalResult }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Current User Profile
        if otherUser == nil {
            self.tabBarController?.tabBar.isHidden = false
            self.navigationItem.leftBarButtonItem = self.settingsBarButton
            self.navigationItem.rightBarButtonItem = self.editProfileBarButton
            self.tabBarController?.navigationItem.hidesBackButton = true
            checkForExistingProfile()
        } else {
            // Other User Profile
            self.tabBarController?.tabBar.isHidden = true
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            self.tabBarController?.navigationItem.hidesBackButton = false
            
            if let completedQuizIDs = self.otherUser?.userQuizHistory.map({ $0.quizID }), !completedQuizIDs.isEmpty {
                fetchQuizHistory(completedQuizIDs: completedQuizIDs)
            } else {
                self.updateCollectionView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:  SupplementaryViewKind.sectionHeader,  withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
        
    }
    
    func checkForExistingProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document {
                
                if document.exists {
                    self.fetchUser()
                    return
                } else {
                    self.performSegue(withIdentifier: "editProfile", sender: true) // Mandatory
                }
            }
        }
        
    }
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    private func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.user = user
                
                self.updateCollectionView()
                
            case .failure(let error):
                // could not be initialized from the DocumentSnapshot.
                self.presentErrorAlert(with: error.localizedDescription)
            }
        }
    }
    
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .profile(let user):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileInfo", for: indexPath) as! ProfileInfoCollectionViewCell
                
                cell.configure(withUsername: user.username, withPoints: user.points, withCorrectGuesses: user.correctGuesses, withWrongGuesses: user.wrongGuesses)
                
                return cell
            case .emoji(let resultType, let isHidden):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserEmoji", for: indexPath) as! ProfileEmojiCollectionViewCell
                
                cell.configure(withResultType: resultType, isHidden: isHidden)
                
                return cell
            case .userQuizHistory(let userQuizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileQuizHistory", for: indexPath) as! ProfileQuizHistoryCollectionViewCell
                
                let quizTitle = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })?.title
                
                cell.configure(withQuizTitle: quizTitle, withResultType: userQuizHistory.finalResult, withTimePassed:  Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                
                return cell
            case .hiddenUserQuizHistory(let userQuizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileHiddenQuizHistory", for: indexPath) as! ProfileHiddenQuizHistoryCollectionViewCell
                
                let quizTitle = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })?.title
                
                cell.configure(withQuizTitle: quizTitle, withTimePassed:  Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                
                return cell
            case .noEmojis:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoEmojis", for: indexPath) as! NoEmojisCollectionViewCell
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .profileInfo:
                sectionHeader.configure(title: "Guessed Results", colorName: "Text")
            case .userEmojis:
                sectionHeader.configure(title: "Emoji Collection", colorName: "Text")
            case .userQuizHistory:
                sectionHeader.configure(title: "Past Quiz Results", colorName: "Text")
            }
            
            
            return sectionHeader
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            let horzSpacing: CGFloat = 20
            
            let sectionHeaderItemSize =
            NSCollectionLayoutSize(widthDimension:
                    .fractionalWidth(1), heightDimension: .estimated(48))
            let sectionHeader =
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderItemSize, elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
            
            // Profile info
            if sectionIndex == 0  {
               
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(360))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
//                group.contentInsets = NSDirectionalEdgeInsets(
//                    top: 0,
//                    leading: infoHorzSpacing,
//                    bottom: vertSpacing,
//                    trailing: infoHorzSpacing
//                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 30,
                    trailing: 0
                )
                    
                return section
            } else if sectionIndex == 1  {
                // emoji
                
                // No Emojis
                if sectionIndex == self.dataSource.snapshot().sectionIdentifiers.firstIndex(of: .userEmojis) && self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: sectionIndex)) == .noEmojis {
                    
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
                    
                    section.boundarySupplementaryItems = [sectionHeader]
                    
                    let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: SupplementaryViewKind.sectionBackgroundView)
                    
                    backgroundItem.contentInsets = NSDirectionalEdgeInsets(
                        top: 8,
                        leading: 20,
                        bottom: 20,
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
                           
                } else {
                    
                    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(50), heightDimension: .absolute(50))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(54))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    group.interItemSpacing = .fixed(12)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.boundarySupplementaryItems = [sectionHeader]
                    
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
                }
                
            } else {
                // user history
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(96))
                
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
                section.boundarySupplementaryItems = [sectionHeader]
                
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: horzSpacing,
                    bottom: 10,
                    trailing: horzSpacing
                )
                
                return section
            }
        }
        
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SupplementaryViewKind.sectionBackgroundView)
        return layout
    }
    
    func updateCollectionView() {
        
        guard let profileUser = otherUser != nil ? otherUser : self.user, let currentUid = Auth.auth().currentUser?.uid else { return }
        print("collection view profileUser \(profileUser)")
        
        
        var sectionIDs = [ViewModel.Section]()
        
        sectionIDs.append(.profileInfo)
        var itemsBySection = [ViewModel.Section.profileInfo: [ViewModel.Item.profile(user: profileUser)]]
        
        //        let resultTypeItems = getResultTypes(userQuizHistories: profileUser.userQuizHistory).reduce(into: [ViewModel.Item]()) { partial, resultType in
        //            let item = ViewModel.Item.emoji(resultType: resultType)
        //            partial.append(item)
        //        }
        
        sectionIDs.append(.userEmojis)
        
        sectionIDs.append(.userQuizHistory)
        
        if otherUser != nil {
            
            for userQuizHistory in profileUser.userQuizHistory {
                if let quizHistory = model.quizHistories.first(where: { $0.quizID == userQuizHistory.quizID }),
                   quizHistory.completedUsers.contains(profileUser.uid) {
                    
                    if let matchingQuizHistory = profileUser.userQuizHistory.first(where: { $0.quizID == userQuizHistory.quizID }) {
                        if matchingQuizHistory.membersGuessed.contains(currentUid) {
                            print("\(userQuizHistory.quizID) .userquizhistory not hidennn")
                            itemsBySection[.userQuizHistory, default: []].append(ViewModel.Item.userQuizHistory(userQuizHistory: matchingQuizHistory))
                            itemsBySection[.userEmojis, default: []].append(ViewModel.Item.emoji(resultType: userQuizHistory.finalResult, isHidden: false))
                        } else {
                            print("\(userQuizHistory.quizID) .hiddennn")
                            itemsBySection[.userQuizHistory, default: []].append(ViewModel.Item.hiddenUserQuizHistory(userQuizHistory: matchingQuizHistory))
                            
                            itemsBySection[.userEmojis, default: []].append(ViewModel.Item.emoji(resultType: userQuizHistory.finalResult, isHidden: true))
                        }
                    }
                }
            }
        } else {
            
            let resultTypeItems = getResultTypes(userQuizHistories: profileUser.userQuizHistory).reduce(into: [ViewModel.Item]()) { partial, resultType in
                let item = ViewModel.Item.emoji(resultType: resultType, isHidden: false)
                partial.append(item)
            }
            
            itemsBySection[.userEmojis] = resultTypeItems
            
            let quizHistoryItems = profileUser.userQuizHistory.reduce(into: [ViewModel.Item]()) { partial, userQuizHistory in
                
                let item = ViewModel.Item.userQuizHistory( userQuizHistory: userQuizHistory)
                partial.append(item)
            }
            
            itemsBySection[.userQuizHistory] = quizHistoryItems
            
        }
        
        
        if let emojiSection = itemsBySection[.userEmojis], emojiSection.isEmpty {
            itemsBySection[.userEmojis] = [ViewModel.Item.noEmojis]
        }
        
        
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
        print("itemsbyseeection \(itemsBySection)")
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func fetchQuizHistory(completedQuizIDs: [Int]) {
        
        self.model.quizHistories.removeAll()
        
        FirestoreService.shared.db.collection("quizHistories").whereField("quizID", in: completedQuizIDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentErrorAlert(with: error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        self.model.quizHistories.append(try document.data(as: QuizHistory.self))
                    } catch {
                        self.presentErrorAlert(with: error.localizedDescription)
                    }
                }
                self.updateCollectionView()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let sectionIndex = indexPath.section
                
        if self.dataSource.snapshot().sectionIdentifiers[sectionIndex]  == .userQuizHistory {
            UIView.animate(withDuration: 0.1) {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    
                cell?.contentView.backgroundColor = UIColor(named: "cellHighlight")
                
            }
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let sectionIndex = indexPath.section
        
        if self.dataSource.snapshot().sectionIdentifiers[sectionIndex]  == .userQuizHistory {
            UIView.animate(withDuration: 0.1) {
                cell?.transform = .identity
                cell?.contentView.backgroundColor = UIColor.white
            }
        }
    }
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToProfileCollectionVC(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        self.fetchUser()
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func editProfileButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editProfile", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfile" {
            let navController = segue.destination as! UINavigationController
            let editProfileVC = navController.topViewController as! EditProfileTableViewController
            editProfileVC.user = user
            
            if let isMandatorySignUp = sender as? Bool {
                editProfileVC.isMandatorySignUp = isMandatorySignUp
            } else {
                editProfileVC.isMandatorySignUp = false
            }
            
        } else if segue.identifier == "resultFromProfile" {
            let navController = segue.destination as! UINavigationController
            let quizResultVC = navController.topViewController as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (UserQuizHistory) {
                
                let userQuizHistory = senderInfo
                quizResultVC.quiz = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })
                
                if otherUser != nil {
                    quizResultVC.resultUser = otherUser
                    quizResultVC.quizResultType = .checkOtherResult
                } else {
                    quizResultVC.resultUser = self.user
                    quizResultVC.quizResultType = .checkOwnResult
                }
                
                quizResultVC.userQuizHistory = userQuizHistory
            }
            
        } else if segue.identifier == "guessFromProfile" {
            print("i'm in")
            let guessQuizVC = segue.destination as! GuessQuizViewController
            
            
            if let senderInfo = sender as? UserQuizHistory {
                let userQuizHistory = senderInfo
                
                print("myquizhiosoo\(userQuizHistory)")
                
                guessQuizVC.guessedMember = otherUser
                guessQuizVC.userQuizHistory = userQuizHistory
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .userQuizHistory(let userQuizHistory):
                self.performSegue(withIdentifier: "resultFromProfile", sender: userQuizHistory)
            case .hiddenUserQuizHistory(let userQuizHistory):
                self.performSegue(withIdentifier: "guessFromProfile", sender: userQuizHistory)
            default:
                break
            }
        }
    }
    
}
