//
//  Prices.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-06.
//

import Foundation

struct Padding {
    static let smallItemVertPadding: CGFloat = 12
    static let smallItemHorzPadding: CGFloat = 20
}
    
struct Price {
    // Heart
    static let guessForTmate = 1
    static let takeQuiz = 0
    
    // Dollar
    static let retakeQuiz = 2
}

struct Points {
    static let takeQuiz = 5
    static let retakeQuiz = 1
    static let guessCorrect = 3
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

enum SupplementaryViewKind {
    static let sectionHeader = "sectionHeader"
    static let searchBar = "searchBar"
    static let sectionBackgroundView = "sectionBackgroundView"
    
    static let topLine = "topLine"
    static let bottomLine = "bottomLine"
}
