//
//  TmateEmojisCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-18.
//

import UIKit

class TmateEmojisCollectionViewCell: UICollectionViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var emojisLabel: UILabel!
    
    func configure(username: String?, points: Int, resultTypes: [ResultType?], isCurrentUser: Bool) {
        
        if isCurrentUser {
            usernameLabel.applyStyle(labelType: .currentUser)
        } else {
            usernameLabel.text = username
            usernameLabel.applyStyle(labelType: .otherUser)
        }
        
        pointsLabel.text = "\(points) pts"
        emojisLabel.text = getEmojiList(resultTypes: resultTypes)
                
        self.applyRoundedCornerAndShadow(borderType: .smallItem)
    }
    
    func getEmojiList(resultTypes: [ResultType?]) -> String {
        return resultTypes.map { $0?.emoji ?? "?" }.joined(separator: " ")
    }
}
