//
//  ProfileEmojiCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-13.
//

import UIKit

class ProfileEmojiCollectionViewCell: UICollectionViewCell {
    @IBOutlet var emojiLabel: UILabel!
    
    func configure(withEmoji emoji: String) {
        emojiLabel.text = emoji
        
        emojiLabel.applyRoundedCornerAndShadow(borderedLabelType: .profileEmoji)
    }
}
