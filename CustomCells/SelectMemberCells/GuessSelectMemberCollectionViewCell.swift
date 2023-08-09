//
//  GuessMemberSelectionCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-08.
//

import UIKit

class GuessSelectMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
        
    func configure(withUsername username: String) {
        
        usernameLabel.text = username
    }
}
