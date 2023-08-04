//
//  ProfileInfoCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit

class ProfileInfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    
    func configure(withUsername username: String, withBio bio: String?) {
        usernameLabel.text = username
        if let bio = bio {
            bioLabel.text = bio
        }
    }
    
}
