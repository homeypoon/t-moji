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
    
    
    func configure(withUsername userName: String, withResultType resultType: ResultType) {
        
        usernameLabel.text = userName
        resultTitleLabel.text = "\(resultType.emoji) \(resultType.rawValue.capitalized)"
        resultDescriptionLabel.text = resultType.message
    }
}
