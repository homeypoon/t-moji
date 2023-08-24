//
//  QuizSummaryCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-14.
//

import UIKit

class QuizSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var completeQuizLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var pointsDescriptionLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelProgressView: UIProgressView!
    @IBOutlet var pointsProgressLabel: UILabel!
    
    private var progressUpdated = false
    
    func configure(quizTitle: String?, isRetake: Bool, withPoints currentPoints: Int) {
        
        quizTitleLabel.text = quizTitle
        
        // if guessedResultType == resultType
        if isRetake {
            completeQuizLabel.text = "Quiz Retaken"
            pointsLabel.text = "+ \(Points.retakeQuiz) pts"
            pointsDescriptionLabel.text = "Quiz Retaken"
        } else {
            completeQuizLabel.text = "Quiz Completed"
            pointsLabel.text = "+ \(Points.takeQuiz) pts"
            pointsDescriptionLabel.text = "Quiz Completed"
        }
        
        self.applyRoundedCornerAndShadow(borderType: .topBigBanner)
        
        print("currentPoints \(currentPoints)")
        
        //        levelLabel.text = "\(correspondingLevel)"
        
        levelLabel.applyStyle(labelType: .level)
        
        levelProgressView.applyStyle(progressType: .levelProgress)
        
        if !progressUpdated {
            let initialPoints = isRetake ? currentPoints - Points.retakeQuiz : currentPoints - Points.takeQuiz
            updateProgress(initialPoints: initialPoints, currentPoints: currentPoints)
            progressUpdated = true
        }
    }
    
    func updateProgress(initialPoints: Int, currentPoints: Int) {
        let initialLevelTracker = LevelTracker(userPoints: initialPoints)
        let currentLevelTracker = LevelTracker(userPoints: currentPoints)
        
        print("updating progress")
        
        if initialLevelTracker.currentLevel == currentLevelTracker.currentLevel {
            updateProgressWhenNoLevelChange(initialLevelTracker: initialLevelTracker, currentLevelTracker: currentLevelTracker, noPointsChange: initialLevelTracker.userPoints == currentLevelTracker.userPoints)
            print("no level change")
        } else {
            print("level change")
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
            print("no points changed")
        } else {
            // Points Changed
            pointsProgressLabel.text = "\(initialLevelTracker.userPoints) / \(initialLevelTracker.nextLevelPointsThreshold)"
            var progressValue = Float(initialLevelTracker.pointsInLevel) / Float(initialLevelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: false)
            
            // Update to current points
            progressValue = Float(currentLevelTracker.pointsInLevel) / Float(currentLevelTracker.requiredPointsToNextLevel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.levelProgressView.setProgress(progressValue, animated: true)
                
                self.pointsProgressLabel.text = "\(currentLevelTracker.userPoints) / \(currentLevelTracker.nextLevelPointsThreshold)"
            }
            
            print("points changed")
        }
    }
    
    func updateProgressWithLevelChange(initialLevelTracker: LevelTracker, currentLevelTracker: LevelTracker) {
        levelLabel.text = "\(initialLevelTracker.currentLevel)"
        
        if currentLevelTracker.isMaxLevel {
            pointsProgressLabel.text = "\(currentLevelTracker.userPoints) (MAX LEVEL)"
            
            levelProgressView.setProgress(1.0, animated: true)
        } else {
            // Set inital points to next threshold
            print("initialLevelTracker.userpoints \(initialLevelTracker.userPoints)")
            print("initialLevelTracker.nextLevelPointsThreshold \(initialLevelTracker.nextLevelPointsThreshold)")
            
            pointsProgressLabel.text = "\(initialLevelTracker.userPoints) / \(initialLevelTracker.nextLevelPointsThreshold)"
            var progressValue = Float(initialLevelTracker.pointsInLevel) / Float(initialLevelTracker.requiredPointsToNextLevel)
            
            levelProgressView.setProgress(progressValue, animated: false)
            
            // Delay the initial animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.levelProgressView.setProgress(Float(initialLevelTracker.requiredPointsToNextLevel) / Float(initialLevelTracker.requiredPointsToNextLevel), animated: true)
            }
            
            // Delay the resetting of the progress view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                self.levelProgressView.setProgress(Float(0) / Float(currentLevelTracker.requiredPointsToNextLevel), animated: true)
            }
            
            // Set threshold to current points
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                progressValue = Float(currentLevelTracker.pointsInLevel) / Float(currentLevelTracker.requiredPointsToNextLevel)
                
                self.levelProgressView.setProgress(progressValue, animated: true)
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {

                // Animate levelLabel to become bigger and bounce
                UIView.animate(withDuration: 0.5, animations: {
                    self.levelLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) // Scale up
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 7, options: [], animations: {
                        self.levelLabel.transform = .identity // Bounce back
                    }, completion: nil)

                    // Update label text
                    UIView.transition(with: self.levelLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.levelLabel.text = "\(currentLevelTracker.currentLevel)"
                        self.levelProgressView.setProgress(progressValue, animated: true)
                        self.pointsProgressLabel.text = "\(currentLevelTracker.userPoints) / \(currentLevelTracker.nextLevelPointsThreshold)"
                    }, completion: nil)
                })

            }
            print("level changed, points changed")
        }
    }
}
