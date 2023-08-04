//
//  PotentialGroupMemberTableViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit

protocol PotentialGroupMemberCellDelegate: AnyObject {
    func addToGroupButtonTapped(sender: PotentialGroupMemberTableViewCell)
}

class PotentialGroupMemberTableViewCell: UITableViewCell {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var addToGroupButton: UIButton!
    weak var delegate: PotentialGroupMemberCellDelegate?
    
    func configure(withUsername username: String) {
        usernameLabel?.text = username
    }
    
    @IBAction func addToGroupButtonTapped(_ sender: UIButton) {
        delegate?.addToGroupButtonTapped(sender: self)
    }
    

}
