//
//  User.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct User {
    typealias QuizID = UUID
    typealias GroupID = String
    
    var uid: String
    var username: String = ""
    var bio: String? = ""
    
    @ServerTimestamp var joinTimestamp: Timestamp?
    
    var masterGroupmatesIDs: [String] = [] // Use as a set - get unique
    
    var groupsIDs: [GroupID] = []
    var quizHistory: [UserQuizHistory] = []
    
    var isSelected: Bool = false
    
    var dollarCount: Int = 0
    var heartCount: Int = 0

}

extension User: Codable { }

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.username < rhs.username
    }
}

