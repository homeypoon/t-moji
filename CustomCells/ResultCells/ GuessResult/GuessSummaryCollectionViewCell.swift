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

