//
//  HomeTopBannerCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-27.
//

import UIKit

protocol HomeTopBannerDelegate: AnyObject {
    func createGroupButtonPressed()
}

class HomeTopBannerCollectionViewCell: UICollectionViewCell {
    weak var delegate: HomeTopBannerDelegate?
    
    @IBOutlet var createTeamButton: UIButton!
    
    func configure() {
//        createTeamButton.applyRoundedCornerAndShadow(borderType: .quizButton)
    }
    
    
    @IBAction func createGroupButtonPressed(_ sender: UIButton) {
        delegate?.createGroupButtonPressed()
    }
    
}
