//
//  ProfileQuizHistoryCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-13.
//

import UIKit

class ProfileQuizHistoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    
    
    func configure(withQuizTitle quizTitle: String?, withResultType resultType: ResultType?, withTimePassed timePassed: String) {
        
        emojiLabel.text = resultType?.emoji
        quizTitleLabel.text = quizTitle
        timePassedLabel.text = timePassed
        
        self.applyRoundedCornerAndShadow(borderType: .smallStrong)
    }
}
