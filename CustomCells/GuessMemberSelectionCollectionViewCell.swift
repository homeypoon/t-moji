//
//  GuessMemberSelectionCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-08.
//

import UIKit

class GuessMemberSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var chevronImageView: UIImageView!
    
    func configure(isGuessed: Bool, withUsername username: String, withResultType resultType: ResultType?) {
        
        if isGuessed {
            emojiLabel.text = resultType?.emoji
            emojiLabel.font = UIFont.systemFont(ofSize: 40.0, weight: .heavy)
            chevronImageView.isHidden = true
        } else {
            emojiLabel.text = "?"
            emojiLabel.font = UIFont.systemFont(ofSize: 44.0, weight: .heavy)
            chevronImageView.isHidden = false
        }
        
        usernameLabel.text = username
        
    }
}
