//
//  ExploreQuizCollectionViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-03.
//

import UIKit

class ExploreQuizCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var quizTitleLabel: UILabel!
    @IBOutlet var takenByOthersLabel: UILabel!
    
    @IBOutlet var resultGroupButton: UIButton!
    @IBOutlet var completeStateButton: UIButton!
    
    func configure(quiz: Quiz, completeState: Bool, currentUserResultType: ResultType?, takenByText: String) {
        
        resultGroupButton.applyRoundedCornerAndShadow(borderType: .exploreTag)
        completeStateButton.applyRoundedCornerAndShadow(borderType: .exploreTag)
        
        
        resultGroupButton.tintColor = UIColor(named: "primaryLightRed")

        resultGroupButton.layer.borderColor = UIColor(named: "primaryRed")?.cgColor
        
        resultGroupButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            outgoing.backgroundColor = UIColor(named: "primaryLightRed")
            outgoing.foregroundColor = UIColor(named: "primaryRed")
            return outgoing
        }
        resultGroupButton.setTitle(quiz.resultGroup.rawValue.capitalized, for: [])
        
        quizTitleLabel.text = quiz.title
        
        if completeState == true {
            completeStateButton.setTitle("Result: \(currentUserResultType?.emoji ?? " ")", for: .normal)
            
            completeStateButton.configuration?.baseBackgroundColor = UIColor(named: "primaryLightOrange")
            completeStateButton.layer.borderColor = UIColor(named: "primaryDarkOrange")?.cgColor
            
            completeStateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                outgoing.backgroundColor = UIColor(named: "primaryLightOrange")
                outgoing.foregroundColor = UIColor(named: "primaryDarkOrange")
                return outgoing
            }
        } else {
            completeStateButton.setTitle("Not Taken", for: .normal)
            
            completeStateButton.configuration?.baseBackgroundColor = UIColor(named: "primaryDarkOrange")
            completeStateButton.layer.borderColor = UIColor(named: "primaryDarkOrange")?.cgColor
            
            completeStateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                outgoing.backgroundColor = UIColor(named: "primaryDarkOrange")
                outgoing.foregroundColor = UIColor(named: "white")
                return outgoing
            }
            
        }
        takenByOthersLabel.text = takenByText
        
        self.applyRoundedCornerAndShadow(borderType: .exploreItem)
    }
}
