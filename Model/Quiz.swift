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
    
    var questions: [Question]
            
    func calculateResult(chosenAnswers: [Int: [Answer]]) -> ResultType {
        var answerFrequency: [ResultType: Int] = [:]

        for answersArray in chosenAnswers.values {
            for answer in answersArray {
                answerFrequency[answer.correspondingResult, default: 0] += 1
            }
        }
        
        let sortedAnswerFrequency = answerFrequency.sorted(by: {
            (pair1, pair2) in
            return pair1.value > pair2.value
        })
        
        let result = sortedAnswerFrequency.sorted { $0.1 > $1.1 }.first!.key
        
        return result
    }
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
    case multipleChoice, ranged
}

struct Answer: Codable {
    var text: String
    var correspondingResult: ResultType
    var rangedValue: Float?
}
