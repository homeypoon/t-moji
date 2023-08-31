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
    @IBOutlet var levelLabel: UILabel!
    
    func configure(withOrdinal ordinal: String, withUsername username: String?, withPoints points: Int, isCurrentUser: Bool) {
        if isCurrentUser {
            usernameLabel.text = "Me"
            usernameLabel.textColor = UIColor(named: "darkCurrentUserText")
        } else {
            usernameLabel.textColor = UIColor(named: "Text")
            usernameLabel.text = username
        }
        
        ordinalLabel.text = ordinal
        pointsLabel.text = "\(points) pts"

        let levelTracker = LevelTracker(userPoints: points)
        
        levelLabel.text = !levelTracker.isMaxLevel ? "lvl \(levelTracker.currentLevel)" : "(MAX LEVEL)"
        
        self.applyRoundedCornerAndShadow(borderType: .remainingLeaderboard)
    }
}
