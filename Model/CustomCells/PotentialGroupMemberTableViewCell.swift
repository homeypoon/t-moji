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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(withUsername username: String) {
        usernameLabel?.text = username
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addToGroupButtonTapped(_ sender: UIButton) {
        delegate?.addToGroupButtonTapped(sender: self)
    }
    

}
