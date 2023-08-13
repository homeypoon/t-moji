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
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelProgressView: UIProgressView!
    @IBOutlet var pointsProgressLabel: UILabel!
    
    
    func configure(withUsername username: String, withBio bio: String?, withPoints currentPoints: Int) {
        usernameLabel.text = username
        if let bio = bio {
            bioLabel.text = bio
        }
        
        
        levelLabel.applyStyle(labelType: .level)
        levelProgressView.applyStyle(progressType: .levelProgress)
        
        let (correspondingLevel, maxPointsForCurrentLevel) = Levels.getCorrespondingLevelAndMaxPoints(for: currentPoints)
        print("currentPoints \(currentPoints)")
        
        levelLabel.text = "\(correspondingLevel)"

        updateProgress(for: currentPoints, maxPoints: maxPointsForCurrentLevel, animated: false)
    }
    
    func updateProgress(for currentPoints: Int, maxPoints: Float, animated: Bool) {
        let progressValue = Float(currentPoints) / maxPoints
        levelProgressView.setProgress(progressValue, animated: animated)
        pointsProgressLabel.text = "\(currentPoints)/\(Int(maxPoints))"
    }
}
