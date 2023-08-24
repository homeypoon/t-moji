//
//  ExtraGuessPopupView.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-22.
//

import UIKit

protocol ExtraGuessPopupViewDelegate: AnyObject {
    func extraGuessGranted()
    
    func noThanksButtonClicked()
}

class ExtraGuessPopupView: UIView {
    
    weak var delegate: ExtraGuessPopupViewDelegate?
    

    @IBOutlet weak var countdownLabel: UILabel!
    
    var countdownValue = 5
    var countdownTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        self.applyRoundedCornerAndShadow(viewType: .extraGuessPopup)
    }
    
    func restartCountdown() {
        countdownValue = 5
        countdownTimer?.invalidate()
        
        countdownLabel.text = "Video Starting in \(countdownValue)..."
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        countdownValue -= 1
        countdownLabel.text = "Video Starting in \(countdownValue)..."
        if countdownValue == 0 {
            countdownTimer?.invalidate()
            hidePopup()
            delegate?.extraGuessGranted()
        }
    }
    
    func hidePopup() {
        countdownTimer?.invalidate()
        
        // Animate the popup view out of sight
        self.isHidden = true
    }
    
    @IBAction func noThanksButtonClicked(_ sender: UIButton) {
        hidePopup()
        delegate?.noThanksButtonClicked()
    }

    @IBAction func getExtraGuessButtonClicked(_ sender: UIButton) {
        hidePopup()
        delegate?.extraGuessGranted()
    }
}
