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
        
        let (correspondingLevel, minPointsForCurrentLevel, maxPointsForCurrentLevel) = Levels.getCorrespondingLevelAndMaxPoints(for: currentPoints)
        print("currentPoints \(currentPoints)")
        
        levelLabel.text = "\(correspondingLevel)"

        updateProgress(for: currentPoints, minPoints: minPointsForCurrentLevel, maxPoints: maxPointsForCurrentLevel, animated: false)
        
        updateGuessStats(correctGuesses: correctGuesses, wrongGuesses: wrongGuesses)
    }
    
    func updateProgress(for currentPoints: Int, minPoints: Float, maxPoints: Float, animated: Bool) {
        let progressValue = (Float(currentPoints) - minPoints) / (maxPoints - minPoints)
        
        print("min \(minPoints)")
        print("max \(maxPoints)")
        levelProgressView.setProgress(progressValue, animated: animated)
        pointsProgressLabel.text = "\(currentPoints) / \(Int(maxPoints))"
    }
    
    func updateGuessStats(correctGuesses: Int, wrongGuesses: Int) {
        correctGuessCountLabel.text = "\(correctGuesses)"
        wrongGuessCountLabel.text = "\(wrongGuesses)"
        
        let guessAccuracy = Double(correctGuesses) / Double(correctGuesses + wrongGuesses) * 100
        
        

        guessAccuracyCountLabel.text = !guessAccuracy.isNaN ? String(format: "%.0f%%", guessAccuracy) : "N / A"
    }
}
