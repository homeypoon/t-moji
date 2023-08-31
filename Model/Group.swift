//
//  Group.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Group: Codable {
    typealias MemberUserID = String
    @DocumentID var id: String?
    
    var name: String
    var emoji: String
    
    var membersIDs: [MemberUserID]
}

extension Group: Hashable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Group: Comparable {
    static func < (lhs: Group, rhs: Group) -> Bool {
        return lhs.name < rhs.name
    }
    
}
