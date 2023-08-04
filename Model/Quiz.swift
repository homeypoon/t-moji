//
//  Quiz.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

struct Quiz: Identifiable {
    
    let id: Int
    
    var resultGroup: ResultGroup // Animal, Fruit, Vehicle (also used as the name)
    var title: String // Long
    
    var quizType: QuizType
    
    var question: [Question]
        
    var questionIndex: Int? = 0 // Used to see which question the user is on
}

extension Quiz: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Quiz, rhs: Quiz) -> Bool {
        return lhs.id == rhs.id
    }
}


enum QuizType: Codable {
    case character
}

struct Question {
    var id: UUID = UUID()
    var text: String
    var type: QuestionType
    var possibleAnswers: [Answer]
}

enum QuestionType: Codable {
    case singleChoice, multipleChoice, ranged
}

struct Answer: Codable {
    var text: String
    var correspondingResult: ResultType
}
