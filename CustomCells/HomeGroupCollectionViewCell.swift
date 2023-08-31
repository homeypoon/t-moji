//
//  GroupHomeCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-21.
//

import UIKit

class HomeGroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet var groupNameLabel: UILabel!
    @IBOutlet var groupEmojiLabel: UILabel!
    
    func configure(groupName: String, groupEmoji: String) {
        groupNameLabel.text = groupName
        groupEmojiLabel.text = groupEmoji
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
}
