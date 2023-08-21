//
//  ProfileEmojiCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-13.
//

import UIKit

class ProfileEmojiCollectionViewCell: UICollectionViewCell {
    @IBOutlet var emojiLabel: UILabel!
    
    func configure(withResultType resultType: ResultType, isHidden: Bool) {
        if !isHidden {
            emojiLabel.text = resultType.emoji
        } else {
            emojiLabel.text = "?"
        }
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
}
