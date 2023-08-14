//
//  ProfileInfoCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-02.
//

import UIKit

class ProfileInfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelProgressView: UIProgressView!
    @IBOutlet var pointsProgressLabel: UILabel!
    
    func configure(withUsername username: String, withPoints currentPoints: Int) {
        usernameLabel.text = username
        
        levelLabel.applyStyle(labelType: .level)
        levelProgressView.applyStyle(progressType: .levelProgress)
        
        self.applyRoundedCornerAndShadow(borderType: .big)
        
        let (correspondingLevel, minPointsForCurrentLevel, maxPointsForCurrentLevel) = Levels.getCorrespondingLevelAndMaxPoints(for: currentPoints)
        print("currentPoints \(currentPoints)")
        
        levelLabel.text = "\(correspondingLevel)"

        updateProgress(for: currentPoints, minPoints: minPointsForCurrentLevel, maxPoints: maxPointsForCurrentLevel, animated: false)
    }
    
    func updateProgress(for currentPoints: Int, minPoints: Float, maxPoints: Float, animated: Bool) {
        let progressValue = (Float(currentPoints) - minPoints) / (maxPoints - minPoints)
        
        print("min \(minPoints)")
        print("max \(maxPoints)")
        levelProgressView.setProgress(progressValue, animated: animated)
        pointsProgressLabel.text = "\(currentPoints) / \(Int(maxPoints))"
    }
}
