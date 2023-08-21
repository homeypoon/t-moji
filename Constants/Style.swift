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
        case topBigBanner, exploreItem, smallItem, currentResult, othersResult
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .exploreItem:
            // explore
            self.contentView.layer.cornerRadius = 12.0
            self.contentView.layer.borderWidth = 2
            self.contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
            self.contentView.layer.masksToBounds = true
            
//            self.layer.shadowColor = UIColor.black.cgColor
//            self.layer.shadowOffset = CGSize(width: 3, height: 1.5)
//            self.layer.shadowRadius = 1
//            self.layer.shadowOpacity = 0.8
//            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .smallItem:
            // guess, leaderboard
            self.contentView.layer.cornerRadius = 4.0
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor.black.cgColor
            self.contentView.layer.masksToBounds = true
            
//            self.layer.shadowColor = UIColor.black.cgColor
//            self.layer.shadowOffset = CGSize(width: 1.5, height: 0.5)
//            self.layer.shadowRadius = 1
//            self.layer.shadowOpacity = 0.8
//            self.layer.masksToBounds = false
//            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
        case .topBigBanner:
            
            self.contentView.layer.cornerRadius = 24.0
            self.contentView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            //            self.contentView.layer.borderWidth = 0.1
            //            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 4, height: 6)
            self.layer.shadowRadius = 1
            self.layer.shadowOpacity = 0.8
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            
        case .currentResult:
            self.contentView.layer.cornerRadius = 4.0
            self.contentView.layer.borderWidth = 0.5
            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowRadius = 1
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .othersResult:
            self.contentView.layer.cornerRadius = 2.0
            self.contentView.layer.borderWidth = 0.5
            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowRadius = 1
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        }
        
    }
}

extension UIStackView {
    enum BorderType {
        case big, smallStrong, smallWeak
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .big:
            // explore
            self.layer.cornerRadius = 18.0
            //            self.contentView.layer.borderWidth = 0.1
            //            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowRadius = 2
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        default:
            self.layer.cornerRadius = 1.0
        }
        
    }
}

extension UIButton {
    enum BorderType {
        case big, smallStrong, smallWeak
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .big:
            // explore
            self.layer.cornerRadius = 1.0
            self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 2.0)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 0.0
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 4.0
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            
            
        default:
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowRadius = 2.5
            self.layer.shadowOpacity = 0.7
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        }
    }
    
}

extension UILabel {
    enum LabelType {
        case level
    }
    enum BorderedLabelType {
        case profileEmoji
    }
    
    func applyStyle(labelType: LabelType) {
        print("applying label point")
        self.layer.cornerRadius = 13.0
        self.layer.borderWidth = 0.5
        self.layer.backgroundColor = UIColor.white.cgColor
//        self.layer.borderColor = UIColor.green.cgColor
    }
    
    func applyRoundedCornerAndShadow(borderedLabelType: BorderedLabelType) {
        switch borderedLabelType {
        case .profileEmoji:
            self.layer.cornerRadius = 18.0
                   self.layer.borderWidth = 1.0 // Increase the border width for a stronger border
                   self.layer.borderColor = UIColor.black.cgColor // Change the border color if needed
                   self.layer.masksToBounds = true
                   
                   self.layer.shadowColor = UIColor.black.cgColor
                   self.layer.shadowOffset = CGSize(width: 4, height: 8)
                   self.layer.shadowRadius = 2
                   self.layer.shadowOpacity = 0.5
                   self.layer.masksToBounds = false
                   
                   self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
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
                
        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
    }
    
}



