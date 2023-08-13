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

class ProfileCollectionViewController: UICollectionViewController {
    
    var user: User?
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case profileInfo
            case rankings
            case userEmojis
            case userQuizHistory
        }
        enum Item: Hashable {
            case profile(user: User)
            case ranking(globalRanking: Int, tmateRanking: Int)
            case emoji(resultType: ResultType)
            case userQuizHistory(userQuizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .profile(let user):
                    hasher.combine(user)
                case .ranking(let globalRanking, let tmateRanking):
                    hasher.combine(globalRanking)
                    hasher.combine(tmateRanking)
                case .emoji(let resultType):
                    hasher.combine(resultType)
                case .userQuizHistory(let quizHistory):
                    hasher.combine(quizHistory)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.profile(let lUser), .profile(let rUser)):
                    return lUser == rUser
                case (.emoji(let lEmoji), .emoji(let rEmoji)):
                    return lEmoji == rEmoji
                case (.ranking(let lGlobalRanking, let lTmateRanking), .ranking(let rGlobalRanking, let rTmateRanking)):
                    return lGlobalRanking == rGlobalRanking && lTmateRanking == rTmateRanking
                case (.userQuizHistory(let lQuizHistory), .userQuizHistory(let rQuizHistory)):
                    return lQuizHistory == rQuizHistory
                default:
                    return false
                }
            }
        }
        
    }
    
    struct Model {
        var userQuizHistory = [UserQuizHistory]()
        
        var resultTypes: [ResultType] {
            return userQuizHistory.map { $0.finalResult }
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForExistingProfile()
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
                    self.performSegue(withIdentifier: "editProfile", sender: nil)
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
        self.model.userQuizHistory.removeAll()

        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.user = user
                
                self.model.userQuizHistory = user.userQuizHistory
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
                
                cell.configure(withUsername: user.username, withBio: user.bio, withPoints: user.points)
                
                return cell
            case .ranking(let globalRanking, let tmateRanking):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Ranking", for: indexPath) as! ProfileRankingCollectionViewCell
                
//                cell.configure(withUsername: user.username, withBio: user.bio)
                
                return cell
            case .emoji(let resultType):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserEmoji", for: indexPath) as! ProfileEmojiCollectionViewCell
                
                cell.configure(withEmoji: resultType.emoji)
                
//                content.text = "\(resultType.emoji)"
                
                
                return cell
            case .userQuizHistory(let userQuizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileQuizHistory", for: indexPath) as! ProfileQuizHistoryCollectionViewCell
                let quizTitle = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })?.title
            
                    cell.configure(withQuizTitle: quizTitle, withResultType: userQuizHistory.finalResult, withTimePassed:  Helper.timeSinceUserCompleteTime(from: userQuizHistory.userCompleteTime))
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.sectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SectionHeaderCollectionReusableView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .profileInfo:
                sectionHeader.configure(title: "Guessed Results", colorName: "Text")
            case .rankings:
                sectionHeader.configure(title: "Rankings", colorName: "Text")
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
            
            // Profile info
            if sectionIndex == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else if sectionIndex == 8  {
                // ranking
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = sectionEdgeInsets
                
                return section
            } else if sectionIndex == 1 {
                // emoji section
                let availableWidth = environment.container.effectiveContentSize.width - 20 // 10pt leading + 10pt trailing contentInsets
                let minimumItemWidth: CGFloat = 64 // Set the minimum desired width for each item
                
                // Calculate the number of items that can fit within the available width
                let numberOfItemsInRow = max(1, Int(availableWidth / minimumItemWidth))
                
                // Calculate the actual item width based on the number of items
                let itemWidth = (availableWidth - CGFloat(numberOfItemsInRow - 1) * 4) / CGFloat(numberOfItemsInRow)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(64)) // Set a fixed height here (e.g., 48 points)
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(48)) // Use the same fixed height for the group
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = sectionEdgeInsets

                return section
            } else {
                // user history
                let vertSpacing: CGFloat = 10
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
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
        guard let user = user else { return }

        var sectionIDs = [ViewModel.Section]()
        
        sectionIDs.append(.profileInfo)
        var itemsBySection = [ViewModel.Section.profileInfo: [ViewModel.Item.profile(user: user)]]
        
        let resultTypeItems = model.resultTypes.reduce(into: [ViewModel.Item]()) { partial, resultType in
            let item = ViewModel.Item.emoji(resultType: resultType)
            partial.append(item)
        }
        
        sectionIDs.append(.userEmojis)
        
        itemsBySection[.userEmojis] = resultTypeItems
        
        
        let quizHistoryItems = model.userQuizHistory.reduce(into: [ViewModel.Item]()) { partial, userQuizHistory in
            let item = ViewModel.Item.userQuizHistory( userQuizHistory: userQuizHistory)
            partial.append(item)
        }
        
        sectionIDs.append(.userQuizHistory)
        itemsBySection[.userQuizHistory] = quizHistoryItems
                
        dataSource.applySnapshotUsing(sectionIds: sectionIDs, itemsBySection: itemsBySection)
    }
    
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToProfileCollectionVC(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
                
    }
    
    
    @IBAction func editProfileButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editProfile", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createProfile" {
            let navController = segue.destination as! UINavigationController
            let detailController = navController.topViewController as! EditProfileTableViewController
            detailController.user = nil
        } else if segue.identifier == "editProfile" {
            let navController = segue.destination as! UINavigationController
            let detailController = navController.topViewController as! EditProfileTableViewController
            detailController.user = user
        } else if segue.identifier == "resultFromProfile" {
            let quizResultVC = segue.destination as! QuizResultCollectionViewController
            
            if let senderInfo = sender as? (UserQuizHistory) {
                let userQuizHistory = senderInfo
                quizResultVC.quiz = QuizData.quizzes.first(where: { $0.id == userQuizHistory.quizID })
                quizResultVC.currentUser = self.user
                quizResultVC.userQuizHistory = userQuizHistory
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .userQuizHistory(let userQuizHistory):
                self.performSegue(withIdentifier: "resultFromProfile", sender: userQuizHistory)
            default:
                break
            }
        }
    }

}


extension ProfileCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40) // Return any non-zero size here
    }
}
