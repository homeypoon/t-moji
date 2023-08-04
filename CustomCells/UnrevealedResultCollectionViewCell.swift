//
//  UnrevealedResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

class UnrevealedResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    
    func configure(withUsername userName: String) {
        usernameLabel.text = userName
    }
}
