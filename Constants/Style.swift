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
        case big, smallStrong, smallWeak
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
