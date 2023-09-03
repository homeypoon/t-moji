//
//  UnrevealedResultCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

protocol UnrevealedResultCellDelegate: AnyObject {
    func guessToRevealPressed(sender: UnrevealedResultCollectionViewCell)
}

class UnrevealedResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    weak var delegate: UnrevealedResultCellDelegate?
    
    func configure(withUsername username: String, isCurrentUser: Bool) {
        
        if isCurrentUser {
            usernameLabel.applyStyle(labelType: .currentUser)
        } else {
            usernameLabel.text = username
            usernameLabel.applyStyle(labelType: .otherUser)
        }
        
        self.applyRoundedCornerAndShadow(borderType: .othersResult)
    }
    
    @IBAction func guessToRevealButtonPressed(_ sender: UIButton) {
            delegate?.guessToRevealPressed(sender: self)
        }
    
}
