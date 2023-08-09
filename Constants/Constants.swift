//
//  Prices.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-06.
//

import Foundation

struct Price {
    // Heart
    static let guessForTmate = 1
    static let takeQuiz = 0
    
    // Dollar
    static let retakeQuiz = 2
}

struct Points {
    static let takeQuiz = 3
    static let retakeQuiz = 1
    static let guessCorrect = 5
    static let guessIncorrect = 1
}

struct ButtonState {
    static let takeQuiz = 0
    static let retakeQuiz = 1
}

struct TakenByText {
    static let noTmates = "Not taken by any t-mates yet"
}

enum QuizKind {
    case personal, member
}
