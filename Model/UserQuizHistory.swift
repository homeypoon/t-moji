//
//  UserQuizHistory.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserQuizHistory: Codable {
    
    typealias QuestionIndex = Int
    
    var membersGuessed: [User] = [] // members who have guessed for the current user and quiz

    var quizID: Int
    
    var userCompleteTime: Date // if usercomplete time < closest past tuesday -> don't show profile emoji for this quiz UNLESS they have guessed it
    
    var finalResult: ResultType
    var chosenAnswers: [QuestionIndex: [Answer]]
}

extension UserQuizHistory: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(quizID)
    }
    static func == (lhs: UserQuizHistory, rhs: UserQuizHistory) -> Bool {
        return lhs.quizID == rhs.quizID
    }
}

extension UserQuizHistory: Comparable {
    static func < (lhs: UserQuizHistory, rhs: UserQuizHistory) -> Bool {
        return lhs.finalResult < rhs.finalResult
    }
}

struct MembersQuizHistory: Codable {
    typealias UserID = String
    typealias QuizID = UUID
    typealias QuestionIndex = Int
    
    var id: UUID = UUID()
    var userID: UserID
    var quizID: QuizID
    
    var userCompleteTime: Date // if usercomplete time < closest past tuesday -> don't show profile emoji for this quiz UNLESS they have guessed it
    
    var finalResult: ResultType
    
    var chosenAnswers: [QuestionIndex: [Answer]]
}

extension MembersQuizHistory: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(quizID)
    }
    static func == (lhs: MembersQuizHistory, rhs: MembersQuizHistory) -> Bool {
        return lhs.quizID == rhs.quizID
    }
}

extension MembersQuizHistory: Comparable {
    static func < (lhs: MembersQuizHistory, rhs: MembersQuizHistory) -> Bool {
        return lhs.finalResult < rhs.finalResult
    }
}
