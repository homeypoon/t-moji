//
//  ProfileHiddenQuizHistoryCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-14.
//

import UIKit

class ProfileHiddenQuizHistoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    
    func configure(withQuizTitle quizTitle: String?, withTimePassed timePassed: String) {
        
        quizTitleLabel.text = quizTitle
        timePassedLabel.text = timePassed
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
}
