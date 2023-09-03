//
//  RevealedResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

class RevealedResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var resultTitleLabel: UILabel!
    @IBOutlet var resultDescriptionTextView: UITextView!
    
    
    func configure(withUsername username: String, withResultType resultType: ResultType, isCurrentUser: Bool) {
        
        
        if isCurrentUser {
            usernameLabel.applyStyle(labelType: .currentUser)
        } else {
            usernameLabel.text = username
            usernameLabel.applyStyle(labelType: .otherUser)
        }

        resultTitleLabel.text = "\(resultType.emoji) \(resultType.rawValue.capitalized)"
        resultDescriptionTextView.text = resultType.message
        
        self.applyRoundedCornerAndShadow(borderType: .othersResult)
    }
}
