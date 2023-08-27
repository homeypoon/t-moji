//
//  CurrentUserResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

class CurrentUserResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var resultNameLabel: UILabel!
    @IBOutlet var resultDescriptionTextView: UITextView!
    @IBOutlet var resultIsLabel: UILabel!
    
    
    func configure(withQuizTitle quizTitle: String?, withResultType resultType: ResultType, memberUsername: String?) {
        
        emojiLabel.text = "\(resultType.emoji)"
        resultNameLabel.text = "\(resultType.rawValue.capitalized)"
        resultDescriptionTextView.text = resultType.message
        
        if let username = memberUsername {
            resultIsLabel.text = "\(username) got..."
            self.applyBackground(backgroundType: .othersUser)
        } else {
            resultIsLabel.text = "Your Result is..."
            self.applyBackground(backgroundType: .currentUser)
        }
        
        self.applyRoundedCornerAndShadow(borderType: .currentResult)
    }
}
