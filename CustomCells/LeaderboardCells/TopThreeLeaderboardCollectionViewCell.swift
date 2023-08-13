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

    func configure(withOrdinal ordinal: String, withUsername username: String?, withPoints points: Int) {
        ordinalLabel.text = ordinal
        usernameLabel.text = username
        pointsLabel.text = "\(points) pts"
        
        self.applyRoundedCornerAndShadow(borderType: .smallStrong)
        
    }
}