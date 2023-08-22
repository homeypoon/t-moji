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
        var modifiedUsername = username
        
        if isCurrentUser {
            modifiedUsername = "Me"
            usernameLabel.textColor = .blue
        }

        usernameLabel.text = modifiedUsername
        
        self.applyRoundedCornerAndShadow(borderType: .othersResult)
    }
    
    @IBAction func guessToRevealButtonPressed(_ sender: UIButton) {
            delegate?.guessToRevealPressed(sender: self)
        }
    
}
