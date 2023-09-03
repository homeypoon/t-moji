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
        case topBigBanner, homeTopBanner
        case exploreItem, smallItem
        case currentResult, othersResult, profileEmoji
        case topThreeLeaderboard, remainingLeaderboard
    }
    
    enum BackgroundType {
        case currentUser, othersUser
    }
    
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .exploreItem:
            // explore
            self.contentView.layer.cornerRadius = 12.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 1.7, height: 1.7)
            layer.shadowRadius = 3.2
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            self.contentView.backgroundColor = UIColor.white
            
        case .smallItem:
            // guess, leaderboard
            self.contentView.layer.cornerRadius = 8.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0.5, height: 0.8)
            layer.shadowRadius = 1.5
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            self.contentView.backgroundColor = UIColor.white
        case .topThreeLeaderboard:
            self.contentView.layer.cornerRadius = 8.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1, height: 1)
            layer.shadowRadius = 1.5
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            
        case .remainingLeaderboard:
            self.contentView.layer.cornerRadius = 8.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1, height: 1)
            layer.shadowRadius = 1.5
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            self.contentView.backgroundColor = UIColor.white
            
        case .topBigBanner:
            
            contentView.layer.cornerRadius = 24.0
            contentView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            contentView.layer.masksToBounds = true
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 1.7, height: 1.7)
            layer.shadowRadius = 3.2
            layer.shadowOpacity = 0.8
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
        case .homeTopBanner:
            
            contentView.layer.cornerRadius = 24.0
            contentView.layer.masksToBounds = true
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 1.7, height: 1.7)
            layer.shadowRadius = 3.2
            layer.shadowOpacity = 0.8
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
        case .currentResult:
            self.contentView.layer.cornerRadius = 12.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 3
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            self.contentView.backgroundColor = UIColor.white
            
        case .othersResult:
            self.contentView.layer.cornerRadius = 8.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 1.2)
            layer.shadowRadius = 1.5
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
            self.backgroundColor = UIColor.clear
            self.contentView.backgroundColor = UIColor.white
            
        case .profileEmoji:
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 2.5
            self.contentView.layer.borderColor = UIColor(named: "primaryDarkBlue")?.cgColor
            self.contentView.layer.masksToBounds = true
        }
    }
    
    func applyBackground(backgroundType: BackgroundType) {
        
    }
}

extension UICollectionReusableView {
    enum ReusableViewType {
        case tmatesEmojiCollection
    }
    func applyRoundedCornerAndShadow(reusableViewType: ReusableViewType) {
        switch reusableViewType {
        case .tmatesEmojiCollection:
            var shadowLayer: CAShapeLayer!
            
            if shadowLayer == nil {
                shadowLayer = CAShapeLayer()
                
                shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 24.0).cgPath
                shadowLayer.fillColor = UIColor.white.cgColor
                
                shadowLayer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
                shadowLayer.shadowPath = shadowLayer.path
                shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
                shadowLayer.shadowOpacity = 1
                shadowLayer.shadowRadius = 1.5
                
                layer.insertSublayer(shadowLayer, at: 0)
            }
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
            layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 30, right: 20)
            //            isLayoutMarginsRelativeArrangement = true
            
            layer.cornerRadius = 18.0
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 2.5, height: 4)
            layer.shadowRadius = 5
            layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        }
        
    }
}

extension UIButton {
    enum BorderType {
        case quizDetailButton, quizButton, guessButton
        case quizSubmitButton, guessSubmitButton
        case exploreTag
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .quizDetailButton:
            // explore
            self.layer.cornerRadius = 12.0
            self.layer.shadowColor = UIColor(named: "primaryDarkOrange")?.cgColor
            self.layer.shadowOffset = CGSize(width: 2, height: 3)
            self.layer.shadowOpacity = 0.7
            self.layer.shadowRadius = 3
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            self.backgroundColor = UIColor.clear
            
            
        case .quizSubmitButton:
            self.layer.cornerRadius = 8.0
            self.layer.shadowColor = UIColor(named: "primaryDarkOrange")?.cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 1.0
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 4.0
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            self.backgroundColor = UIColor.clear
            
        case .guessSubmitButton:
            self.layer.cornerRadius = 8.0
            self.layer.shadowColor = UIColor(named: "primaryRed")?.withAlphaComponent(0.8).cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 1.0
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 4.0
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            self.backgroundColor = UIColor.clear
            
        case .quizButton:
            // quiz & guess button
            layer.cornerRadius = 8.0
            layer.masksToBounds = false
            
            layer.shadowColor = UIColor(named: "primaryRed")?.cgColor

            layer.borderColor = UIColor(named: "primaryRed")?.cgColor
            
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1.2, height: 1)
            layer.shadowRadius = 2.7
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath

            backgroundColor = UIColor.clear
        case .guessButton:
            // quiz & guess button
            layer.cornerRadius = 8.0
            layer.masksToBounds = false
            
            layer.shadowColor = UIColor(named: "primaryDarkOrange")?.cgColor

            layer.borderColor = UIColor(named: "primaryDarkOrange")?.cgColor
            
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1.5, height: 1)
            layer.shadowRadius = 3
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath

            backgroundColor = UIColor.clear
        case .exploreTag:
            self.layer.cornerRadius = 10.0
            self.layer.borderWidth = 1.0
            self.isUserInteractionEnabled = false
            self.backgroundColor = UIColor.clear
        }
    }
    
}

extension UILabel {
    enum LabelType {
        case level, currentUser, otherUser
        case leaderboardTopUser, leaderboardRemainingUser
    }
    func applyStyle(labelType: LabelType) {
        
        switch labelType {
        case .level:
            self.layer.cornerRadius = 13.0
            self.layer.backgroundColor = UIColor(named: "white")?.cgColor
            self.textColor = UIColor(named: "primaryDarkOrange")
            
        case .currentUser:
            self.text = "Me"
            self.textColor = UIColor(named: "darkCurrentText")
            self.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        case .otherUser:
            self.textColor = UIColor(named: "Text")
            self.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            
        case .leaderboardTopUser:
            self.textColor = UIColor(named: "Text")
            self.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        case .leaderboardRemainingUser:
            self.textColor = UIColor(named: "Text")
            self.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }
}

extension UITextView {
    enum TextViewType {
        case quizQuestion
    }
    func applyStyle(textViewType: TextViewType) {
        
        switch textViewType {
        case .quizQuestion:
            // explore
            self.layer.cornerRadius = 12.0
            self.layer.masksToBounds = false
            layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 1.4, height: 1.6)
            layer.shadowRadius = 3.5
            
            self.backgroundColor = UIColor.white
            self.textContainerInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        }
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
        
        self.layer.masksToBounds = true
        self.progressViewStyle = .default
        
        // Set the rounded edge for the outer bar
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        // Set the rounded edge for the inner bar
        self.layer.sublayers![1].cornerRadius = 12
        self.subviews[1].clipsToBounds = true
    }
    
}

extension UIView {
    enum ViewType {
        case extraGuessPopup
        case quizDetailBanner
    }
    
    func applyRoundedCornerAndShadow(viewType: ViewType) {
        switch viewType {
        case .extraGuessPopup:
            // explore
            self.layer.cornerRadius = 18.0
            
            self.layer.masksToBounds = true
            
            self.layer.borderWidth = 2.5
            self.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        case .quizDetailBanner:
            // explore
            var shadowLayer: CAShapeLayer!
            
            if shadowLayer == nil {
                shadowLayer = CAShapeLayer()
                
                shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 18.0).cgPath
                shadowLayer.fillColor = UIColor.white.cgColor
                
                shadowLayer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
                shadowLayer.shadowPath = shadowLayer.path
                shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
                shadowLayer.shadowOpacity = 1
                shadowLayer.shadowRadius = 2.5
                
                layer.insertSublayer(shadowLayer, at: 0)
            }
        }
    }
}


