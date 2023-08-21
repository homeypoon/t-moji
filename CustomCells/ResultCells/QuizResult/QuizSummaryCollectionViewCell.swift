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
        
        let (correspondingLevel, minPointsForCurrentLevel, maxPointsForCurrentLevel) = Levels.getCorrespondingLevelAndMaxPoints(for: currentPoints)
        print("currentPoints \(currentPoints)")
        
        levelLabel.text = "\(correspondingLevel)"
        
        levelLabel.applyStyle(labelType: .level)
        
        levelProgressView.applyStyle(progressType: .levelProgress)

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
