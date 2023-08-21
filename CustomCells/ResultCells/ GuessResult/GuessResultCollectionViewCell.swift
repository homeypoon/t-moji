//
//  GuessResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-07.
//

import UIKit

class GuessResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var resultNameLabel: UILabel!
    @IBOutlet var resultDescriptionLabel: UILabel!
    @IBOutlet var youGuessedLabel: UILabel!
    @IBOutlet var userGotLabel: UILabel!
    
    func configure(resultType: ResultType, guessedResultType: ResultType?, username: String?) {

        youGuessedLabel.text = "You guessed \(guessedResultType?.emoji ?? "")"
        userGotLabel.text = "\(username ?? "User") got..."
        
        emojiLabel.text = "\(resultType.emoji)"
        resultNameLabel.text = "\(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
        
        self.applyRoundedCornerAndShadow(borderType: .currentResult)
    }
}
