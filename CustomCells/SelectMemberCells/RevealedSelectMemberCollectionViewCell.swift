//
//  RevealedSelectMemberCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-09.
//

import UIKit

class RevealedSelectMemberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    
    
    func configure(withUsername username: String, withResultType resultType: ResultType?, withTimePassed timePassed: String) {
        
        emojiLabel.text = resultType?.emoji
        usernameLabel.text = username
        timePassedLabel.text = timePassed
        
        self.applyRoundedCornerAndShadow(borderType: .smallStrong)
    }
    
}
