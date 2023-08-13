//
//  GuessMemberSelectionCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-08.
//

import UIKit

class GuessSelectMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    
    func configure(withUsername username: String, withTimePassed timePassed: String) {
        
        usernameLabel.text = username
        timePassedLabel.text = timePassed
        
        self.applyRoundedCornerAndShadow(borderType: .smallStrong)
    }
}
