//
//  CurrentUserResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

class CurrentUserResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var resultNameLabel: UILabel!
    @IBOutlet var resultDescriptionLabel: UILabel!
    @IBOutlet var resultIsLabel: UILabel!
    
    
    func configure(withQuizTitle quizTitle: String?, withResultType resultType: ResultType) {
        
        quizTitleLabel.text = quizTitle
        emojiLabel.text = "\(resultType.emoji)"
        resultNameLabel.text = "\(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
        
        resultIsLabel.text = "Your Result is..."
        
        // else resultIsLabel.text = "\(user) is..."
    }
}
