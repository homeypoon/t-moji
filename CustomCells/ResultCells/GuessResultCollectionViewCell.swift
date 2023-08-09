//
//  GuessResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-07.
//

import UIKit

class GuessResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var resultNameLabel: UILabel!
    @IBOutlet var resultDescriptionLabel: UILabel!
    @IBOutlet var correctLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var youGuessedLabel: UILabel!
    @IBOutlet var userGotLabel: UILabel!
    
    func configure(quizTitle: String?, resultType: ResultType, guessedResultType: ResultType?, username: String?) {
        
        if guessedResultType == resultType {
            correctLabel.text = "Correct!"
            pointsLabel.text = "+ \(Points.guessCorrect) pts"
        } else {
            correctLabel.text = "Incorrect!"
            pointsLabel.text = "+ \(Points.guessIncorrect) pts"
        }
        
        youGuessedLabel.text = "You guessed \(guessedResultType?.emoji ?? "")"
        userGotLabel.text = "\(username ?? "User") got..."
        
        quizTitleLabel.text = quizTitle
        emojiLabel.text = "\(resultType.emoji)"
        resultNameLabel.text = "\(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
    }
}
