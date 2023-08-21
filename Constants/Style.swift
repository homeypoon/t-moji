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
        case profileInfo, big, smallStrong, smallWeak
    }
    func applyRoundedCornerAndShadow(borderType: BorderType) {
        switch borderType {
        case .big:
            // explore
            self.contentView.layer.cornerRadius = 18.0
            //            self.contentView.layer.borderWidth = 0.1
            //            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
            self.layer.shadowRadius = 2
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .smallStrong:
            // guess, leaderboard
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.borderWidth = 0.4
            self.contentView.layer.borderColor = UIColor.gray.cgColor // Use a weaker color, like light gray
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowRadius = 2
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .smallWeak:
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.borderWidth = 0.5
            self.contentView.layer.borderColor = UIColor.gray.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowRadius = 1
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        case .profileInfo:
            
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.borderColor = UIColor.clear.cgColor
            self.contentView.layer.masksToBounds = true

            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.5
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
//            self.contentView.clipsToBounds = true
//            self.contentView.cornerRadius = 10
//            self.contentView.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
//            self.contentView.layer.cornerRadius = 18.0
//            self.contentView.layer.masksToBounds = true
//            self.contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//            self.contentView.clipsToBounds = true
//
//            self.layer.shadowColor = UIColor.black.cgColor
//            self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
//            self.layer.shadowRadius = 2
//            self.layer.shadowOpacity = 0.5
//            self.layer.masksToBounds = false
//
//            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
//            self.clipsToBounds = true
//            self.layer.cornerRadius = 10
            
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
        self.layer.borderWidth = 3.0
        self.layer.backgroundColor = UIColor.green.cgColor
        self.layer.borderColor = UIColor.green.cgColor
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
        self.transform = self.transform.scaledBy(x: 1, y: 4.5)
        
        self.progressTintColor = UIColor(named: "primaryRed")
        self.trackTintColor = UIColor(named: "primaryLightBlue")
        
        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
    }
    
}



