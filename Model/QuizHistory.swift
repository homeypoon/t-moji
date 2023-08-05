//
//  QuizHistory.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import Foundation

struct QuizHistory: Codable {
    typealias UserID = String
    
    var quizID: Int
    
    var completedUsers: [UserID]
}
