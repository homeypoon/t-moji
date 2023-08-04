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
            case userEmojis
            case userQuizHistory
        }
        enum Item: Hashable {
            case profile(user: User)
            case emoji(resultType: ResultType)
            case quizHistory(quizHistory: UserQuizHistory)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .profile(let user):
                    hasher.combine(user)
                case .emoji(let resultType):
                    hasher.combine(resultType)
                case .quizHistory(let quizHistory):
                    hasher.combine(quizHistory)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.profile(let lUser), .profile(let rUser)):
                    return lUser == rUser
                case (.emoji(let lEmoji), .emoji(let rEmoji)):
                    return lEmoji == rEmoji
                case (.quizHistory(let lQuizHistory), .quizHistory(let rQuizHistory)):
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
        
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForExistingProfile()
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    func checkForExistingProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userId)
        
        docRef.getDocument { (document, error) in
            if let document = document {
                
                if document.exists {
                    return
                } else {
                    self.performSegue(withIdentifier: "editProfile", sender: nil)
                }
            }
        }
        
    }
    
//
//    func updateProfileInfoUI() {
//        usernameLabel.text = user?.username
//        bioLabel.text = user?.bio
//
//        self.updateCollectionView()
//    }
//
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update() {
        guard let quizHistory = user?.quizHistory else { return }
        
        model.userQuizHistory = quizHistory
        
        self.updateCollectionView()
    }
    
    private func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = FirestoreService.shared.db.collection("users").document(userID)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.model.userQuizHistory.removeAll()
                self.user = user

                self.update()
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
                
                cell.configure(withUsername: user.username, withBio: user.bio)
                
                return cell
            case .emoji(let resultType):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserEmoji", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.cell()
                
                content.text = "\(resultType.emoji)"
                
                content.textProperties.alignment = .center
                cell.contentConfiguration = content
                
                return cell
            case .quizHistory(let quizHistory):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserQuizHistory", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.cell()
                
                if let quiz = QuizData.quizzes.first(where: { $0.id == quizHistory.quizID }) {
                    content.text = "\(quiz.title)"
                    content.secondaryText = "\(quiz.resultGroup): \(quizHistory.finalResult.emoji)"
                } else {
                    content.text = "Quiz not found"
                }
                cell.contentConfiguration = content
                
                return cell
            }
        }
        
        return dataSource
    }
    
    // Create compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, environment ) -> NSCollectionLayoutSection? in
            
            // Emoji section
            if sectionIndex == 0  {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else if sectionIndex == 1  {
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
                
                
                return section
            } else {
                // user history
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
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
        
        
        let quizHistoryItems = model.userQuizHistory.reduce(into: [ViewModel.Item]()) { partial, quizHistory in
            let item = ViewModel.Item.quizHistory(quizHistory: quizHistory)
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
        
        let sourceViewController = segue.source as! EditProfileTableViewController
        
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
        }
    }

}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40) // Return any non-zero size here
    }
}
