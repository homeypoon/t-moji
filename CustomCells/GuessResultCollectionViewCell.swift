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
    
    
    func configure(withQuizTitle quizTitle: String?, withResultType resultType: ResultType) {
        
        quizTitleLabel.text = quizTitle
        emojiLabel.text = "\(resultType.emoji)"
        resultNameLabel.text = "\(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
    }
}
