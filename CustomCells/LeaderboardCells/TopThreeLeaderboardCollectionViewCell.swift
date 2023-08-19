//
//  LeaderboardCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-10.
//

import UIKit

class TopThreeLeaderboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var ordinalLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var chevronImageView: UIImageView!
    
    func configure(withOrdinal ordinal: String, withUsername username: String?, withPoints points: Int, isCurrentUser: Bool) {
        
        if !isCurrentUser {
            usernameLabel.text = username
            chevronImageView.isHidden = false
        } else {
            usernameLabel.text = "Me"
            chevronImageView.isHidden = true
        }
        
        ordinalLabel.text = ordinal
        pointsLabel.text = "\(points) pts"
        
        self.applyRoundedCornerAndShadow(borderType: .smallStrong)
        
    }
}
