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
    @IBOutlet var resultDescriptionLabel: UILabel!
    
    
    func configure(withUsername username: String, withResultType resultType: ResultType, isCurrentUser: Bool) {
        
        var modifiedUsername = username
        
        if isCurrentUser {
            modifiedUsername = "Me"
            usernameLabel.textColor = .blue
        }

        usernameLabel.text = modifiedUsername
        resultTitleLabel.text = "\(resultType.emoji) \(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
        
        self.applyRoundedCornerAndShadow(borderType: .othersResult)
    }
}
