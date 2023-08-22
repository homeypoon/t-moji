//
//  AddUsersCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-16.
//

import UIKit

protocol AddUsersCollectionViewCellDelegate: AnyObject {
    func addToGroupButtonTapped(for cell: AddUsersCollectionViewCell)
}

class AddUsersCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var addToGroupButton: UIButton!
    
    weak var delegate: AddUsersCollectionViewCellDelegate?

    
    func configure(withUsername username: String?, isSelected: Bool) {
        usernameLabel.text = username
        addToGroupButton.isSelected = isSelected
        
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
    
    @IBAction func addToGroupButtonPressed(_ sender: UIButton) {
        print("tapped")
        delegate?.addToGroupButtonTapped(for: self)
    }
    
}
