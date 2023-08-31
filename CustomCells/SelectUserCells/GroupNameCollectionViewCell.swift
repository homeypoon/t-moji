//
//  GroupNameCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-16.
//

import UIKit

protocol GroupNameCollectionViewCellDelegate: AnyObject {
    func groupNameDidChange(to newName: String)
    func groupEmojiDidChange(to newEmoji: String)
}


class GroupNameCollectionViewCell: UICollectionViewCell {
    @IBOutlet var groupNameTextField: UITextField!
    @IBOutlet var groupEmojiTextField: UITextField!
    weak var delegate: GroupNameCollectionViewCellDelegate?
    
    
    func configure(groupName: String) {
        groupNameTextField.text = groupName
    }
    
    @IBAction func groupNameTextFieldDidChange(_ sender: UITextField) {
        if let newName = sender.text {
            delegate?.groupNameDidChange(to: newName)
        }
    }
    
    @IBAction func groupEmojiTextFieldDidChange(_ sender: UITextField) {
        if let newEmoji = sender.text {
            delegate?.groupEmojiDidChange(to: newEmoji)
        }
    }
    
}
