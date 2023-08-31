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
    @IBOutlet var correctGuessCountLabel: UILabel!
    @IBOutlet var guessAccuracyCountLabel: UILabel!
    @IBOutlet var wrongGuessCountLabel: UILabel!
    
    @IBOutlet var guessStatsStackViews: [UIStackView]!
    
    func configure(withUsername username: String, withPoints currentPoints: Int, withCorrectGuesses correctGuesses: Int, withWrongGuesses wrongGuesses: Int) {
        usernameLabel.text = username
        
        levelLabel.applyStyle(labelType: .level)
        levelProgressView.applyStyle(progressType: .levelProgress)
        
        self.applyRoundedCornerAndShadow(borderType: .topBigBanner)

        updateProgress(for: currentPoints)
        updateGuessStats(correctGuesses: correctGuesses, wrongGuesses: wrongGuesses)
    }
    
    func updateProgress(for currentPoints: Int) {
        let levelTracker = LevelTracker(userPoints: currentPoints)
        
        levelLabel.text = "\(levelTracker.currentLevel)"
        
        if levelTracker.isMaxLevel {
            pointsProgressLabel.text = "\(levelTracker.userPoints) (MAX LEVEL)"
            
            levelProgressView.setProgress(1.0, animated: true)
        } else {
            pointsProgressLabel.text = "\(levelTracker.userPoints) / \(levelTracker.nextLevelPointsThreshold)"
            let progressValue = Float(levelTracker.pointsInLevel) / Float(levelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: true)
            print("progressValue \(progressValue)")
            print("points in level \(levelTracker.pointsInLevel)")
            print("requiredPointsToNextLevel \(levelTracker.requiredPointsToNextLevel)")
        }
    }
    
    func updateGuessStats(correctGuesses: Int, wrongGuesses: Int) {
        correctGuessCountLabel.text = "\(correctGuesses)"
        wrongGuessCountLabel.text = "\(wrongGuesses)"
        
        let guessAccuracy = Double(correctGuesses) / Double(correctGuesses + wrongGuesses) * 100

        guessAccuracyCountLabel.text = !guessAccuracy.isNaN ? String(format: "%.0f%%", guessAccuracy) : "N / A"
    }
}
