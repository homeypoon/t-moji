//
//  GroupHomeCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-21.
//

import UIKit

class HomeGroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet var groupNameLabel: UILabel!
    
    func configure(groupName: String) {
        groupNameLabel.text = groupName
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
}
