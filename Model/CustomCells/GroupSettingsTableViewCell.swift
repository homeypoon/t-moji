//
//  GroupSettingsTableViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-01.
//

import UIKit
import FirebaseAuth

protocol GroupSettingsCellDelegate: AnyObject {
    func manageMemberButtonTapped(sender: GroupSettingsTableViewCell)
}

class GroupSettingsTableViewCell: UITableViewCell {
    @IBOutlet var memberUsernameLabel: UILabel!
    @IBOutlet var memberEmojisLabel: UILabel!
    @IBOutlet var manageMemberButton: UIButton!
    weak var delegate: GroupSettingsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(withMember member: User, withGroupLeader groupLeader: String?, withEmojis emojis: String) {
        
        // Check if current user is the leader
        if let currentUserUID = Auth.auth().currentUser?.uid, let leaderUID = groupLeader,
           (currentUserUID == leaderUID && member.uid != currentUserUID) {
            manageMemberButton.isHidden = false
        } else {
            manageMemberButton.isHidden = true
        }
        
        // If the current member is the leader
        if let leaderUID = groupLeader, member.uid == leaderUID {            memberUsernameLabel?.text = "\(member.username) (t-m leader)"
        } else {
            memberUsernameLabel?.text = member.username
            
        }
        
        memberEmojisLabel?.text = emojis
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func manageMemberButtonTapped(_ sender: UIButton) {
        delegate?.manageMemberButtonTapped(sender: self)
    }
}
