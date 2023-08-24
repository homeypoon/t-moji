//
//  GuessSummaryCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-14.
//

import UIKit

class GuessSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var correctLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var pointsDescriptionLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelProgressView: UIProgressView!
    @IBOutlet var pointsProgressLabel: UILabel!
    
    func configure(quizTitle: String?, isCorrect: Bool, withPoints currentPoints: Int) {
        
        quizTitleLabel.text = quizTitle
        
        // if guessedResultType == resultType
        if isCorrect {
            correctLabel.text = "Correct Guess"
            pointsLabel.text = "+ \(Points.guessCorrect) pts"
            pointsDescriptionLabel.text = "Correct Guess"
        } else {
            correctLabel.text = "Wrong Guess"
            pointsLabel.text = "+ \(Points.guessIncorrect) pt"
            pointsDescriptionLabel.text = "Wrong Guess"
        }
        
        levelLabel.applyStyle(labelType: .level)
        levelProgressView.applyStyle(progressType: .levelProgress)
        
        self.applyRoundedCornerAndShadow(borderType: .topBigBanner)
    
        print("currentPoints \(currentPoints)")
        
        let initialPoints = isCorrect ? currentPoints - Points.guessCorrect : currentPoints - Points.guessIncorrect

        updateProgress(initialPoints: initialPoints, currentPoints: currentPoints)
    }
    
    func updateProgress(initialPoints: Int, currentPoints: Int) {
        let initialLevelTracker = LevelTracker(userPoints: initialPoints)
        let currentLevelTracker = LevelTracker(userPoints: currentPoints)
        
        if initialLevelTracker.currentLevel == currentLevelTracker.currentLevel {
            updateProgressWhenNoLevelChange(initialLevelTracker: initialLevelTracker, currentLevelTracker: currentLevelTracker, noPointsChange: initialLevelTracker.userPoints == currentLevelTracker.userPoints)
        } else {
            updateProgressWithLevelChange(initialLevelTracker: initialLevelTracker, currentLevelTracker: currentLevelTracker)
        }
    }
    
    func updateProgressWhenNoLevelChange(initialLevelTracker: LevelTracker, currentLevelTracker: LevelTracker, noPointsChange: Bool) {
        levelLabel.text = "\(currentLevelTracker.currentLevel)"
        
        // Max Level
        if currentLevelTracker.isMaxLevel {
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) (MAX LEVEL)"
            
            levelProgressView.setProgress(1.0, animated: true)
        } else if noPointsChange {
            // No Points Change
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) / \(currentLevelTracker.nextLevelPointsThreshold)"
            let progressValue = Float(currentLevelTracker.pointsInLevel) / Float(currentLevelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: false)
        } else {
            // Points Changed
            pointsProgressLabel.text = "\(initialLevelTracker.userPoints) / \(initialLevelTracker.nextLevelPointsThreshold)"
            var progressValue = Float(initialLevelTracker.pointsInLevel) / Float(initialLevelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: false)
            
            // Update to current points
            levelProgressView.setProgress(progressValue, animated: true)
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) / \(currentLevelTracker.nextLevelPointsThreshold)"
            progressValue = Float(currentLevelTracker.pointsInLevel) / Float(currentLevelTracker.requiredPointsToNextLevel)
        }
    }
    
    func updateProgressWithLevelChange(initialLevelTracker: LevelTracker, currentLevelTracker: LevelTracker) {
        levelLabel.text = "\(currentLevelTracker.currentLevel)" // change
        
        if currentLevelTracker.isMaxLevel {
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) (MAX LEVEL)"
            
            levelProgressView.setProgress(1.0, animated: true)
        } else if initialLevelTracker.userPoints == currentLevelTracker.userPoints {
            // Set inital points to next threshold
            pointsProgressLabel.text = "\(initialLevelTracker.userPoints) / \(initialLevelTracker.nextLevelPointsThreshold)"
            var progressValue = Float(initialLevelTracker.pointsInLevel) / Float(initialLevelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: false)
            
            levelProgressView.setProgress(1, animated: true)
            levelProgressView.setProgress(0, animated: true)
            
            // Set threshold to current points
            levelProgressView.setProgress(progressValue, animated: true)
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) / \(currentLevelTracker.nextLevelPointsThreshold)"
            progressValue = Float(currentLevelTracker.pointsInLevel) / Float(currentLevelTracker.requiredPointsToNextLevel)
        }
    }
}

