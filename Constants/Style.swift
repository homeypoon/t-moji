//
//  Style.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-11.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    enum BorderType {
        case topBigBanner, exploreItem, smallItem
        case currentResult, othersResult, profileEmoji
        case topThreeLeaderboard, remainingLeaderboard
        case homeGroup, tmatesEmojiCollection
    }
    
    enum BackgroundType {
        case currentUser, othersUser
    }
    
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .exploreItem:
            // explore
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 2
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .smallItem:
            // guess, leaderboard
            self.contentView.layer.cornerRadius = 4.0
            self.contentView.layer.borderWidth = 1.5
            self.contentView.layer.borderColor = UIColor.black.cgColor
            self.contentView.layer.masksToBounds = true
            
        case .topBigBanner:
            
            self.contentView.layer.cornerRadius = 24.0
            self.contentView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.contentView.layer.masksToBounds = true

            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 4, height: 6)
            self.layer.shadowRadius = 0.5
            self.layer.shadowOpacity = 0.8
            self.layer.masksToBounds = false

            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
        case .currentResult:
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 3
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
            
        case .othersResult:
            self.contentView.layer.cornerRadius = 6.0
            self.contentView.layer.borderWidth = 2
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
            
        case .profileEmoji:
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 2.5
            self.contentView.layer.borderColor = UIColor(named: "primaryDarkBlue")?.cgColor
            self.contentView.layer.masksToBounds = true
        case .topThreeLeaderboard:
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 1.5
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
        case .remainingLeaderboard:
            self.contentView.layer.cornerRadius = 4.0
            self.contentView.layer.borderWidth = 1.5
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
        case .homeGroup:
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.borderWidth = 1.5
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
            
        case .tmatesEmojiCollection:
            self.contentView.layer.cornerRadius = 24.0
            self.contentView.layer.borderWidth = 2.5
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
        }
    }
    
    func applyBackground(backgroundType: BackgroundType) {
        
        switch backgroundType {
        case .currentUser:
            self.contentView.backgroundColor = UIColor(named: "primaryPurple")?.withAlphaComponent(0.05)
        case .othersUser:
            self.contentView.backgroundColor = UIColor.white
        }
        
    }
}

extension UIStackView {
    enum BorderType {
        case quizDetailBanner
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .quizDetailBanner:
            // explore
            self.layer.cornerRadius = 18.0
    
            self.layer.masksToBounds = true
            
            self.layer.borderWidth = 2.5
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            
        }
        
    }
}

extension UIButton {
    enum BorderType {
        case quizDetailButton, quizButton
        case quizSubmitButton, guessSubmitButton
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .quizDetailButton:
            // explore
            self.layer.cornerRadius = 8.0
            self.layer.shadowColor = UIColor(named: "primaryPurple")?.cgColor
            self.layer.shadowOffset = CGSize(width: 9, height: 6)
            self.layer.shadowOpacity = 0.3
            self.layer.shadowRadius = 2.5
            self.layer.masksToBounds = false
            
            self.layer.borderWidth = 2.5
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            
            
        case .quizSubmitButton:
            self.layer.cornerRadius = 8.0
            self.layer.shadowColor = UIColor(named: "primaryPurple")?.withAlphaComponent(0.8).cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 1.0
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 4.0
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            
        case .guessSubmitButton:
            self.layer.cornerRadius = 8.0
            self.layer.shadowColor = UIColor(named: "primaryRed")?.withAlphaComponent(0.8).cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 1.0
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 4.0
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        case .quizButton:
            // quiz & guess button
            
            self.layer.cornerRadius = 8.0
            self.layer.masksToBounds = false
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        }
    }
    
}

extension UILabel {
    enum LabelType {
        case level, currentUser, otherUser
    }
    func applyStyle(labelType: LabelType) {
        
        switch labelType {
        case .level:
            self.layer.cornerRadius = 13.0
            self.layer.borderWidth = 0.5
            self.layer.backgroundColor = UIColor.white.cgColor
            //        self.layer.borderColor = UIColor.green.cgColor

        case .currentUser:
            self.text = "Me"
            self.textColor = UIColor(named: "primaryDarkBlue")
            self.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        case .otherUser:
            self.textColor = UIColor(named: "Text")
            self.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        }
        print("applying label point")
        
    }
    
}

extension UIProgressView {
    enum ProgressType {
        case levelProgress
    }
    
    func applyStyle(progressType: ProgressType) {
        self.transform = .identity
        self.transform = self.transform.scaledBy(x: 1, y: 6)
        
        self.progressTintColor = UIColor(named: "progressViewTint")
        self.trackTintColor = UIColor.white
                
        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
    }
    
}



