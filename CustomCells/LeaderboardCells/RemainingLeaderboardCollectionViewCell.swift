//
//  RemaingLeaderboardCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-11.
//

import UIKit

class RemainingLeaderboardCollectionViewCell: UICollectionViewCell {
    @IBOutlet var ordinalLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var chevronImageView: UIImageView!
    
    func configure(withOrdinal ordinal: String, withUsername username: String?, withPoints points: Int, isCurrentUser: Bool) {
        if !isCurrentUser {
            usernameLabel.text = username
            usernameLabel.applyStyle(labelType: .otherUser)
            chevronImageView.isHidden = false
        } else {
            usernameLabel.applyStyle(labelType: .currentUser)
            chevronImageView.isHidden = true
        }
        
        ordinalLabel.text = ordinal
        pointsLabel.text = "\(points) pts"
        
        self.applyRoundedCornerAndShadow(borderType: .remainingLeaderboard)
    }
}
