//
//  UnrevealedTmateCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-09.
//

import UIKit

class UnrevealedTmateCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    
    func configure(withUsername username: String, withQuizTitle quizTitle: String?, withTimePassed timePassed: String) {
        
        usernameLabel.text = username
        quizTitleLabel.text = quizTitle
        timePassedLabel.text = timePassed
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
}
