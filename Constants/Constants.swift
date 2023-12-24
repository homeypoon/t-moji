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
    static let takeQuiz = 10
    static let retakeQuiz = 8
    static let correctTmojiGuess = 3
    static let incorrectTmojiGuess = 1
    static let participationGuess = 1
    static let correctGuessBonus = 2
    
    static func calculatePoints(totalGuesses: Int, correctGuesses: Int, isCorrect: Bool) -> Int {
        let tmojiGuessPoints = isCorrect ? Points.correctTmojiGuess : Points.incorrectTmojiGuess
        
        return (Points.participationGuess * totalGuesses) + (Points.correctGuessBonus * correctGuesses) + tmojiGuessPoints
    }
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
    static let tmateHeader = "tmateHeader"
    static let searchBar = "searchBar"
    static let sectionBackgroundView = "sectionBackgroundView"
    
    static let topLine = "topLine"
    static let bottomLine = "bottomLine"
}
