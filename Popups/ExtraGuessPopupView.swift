//
//  ExtraGuessPopupView.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-22.
//

import UIKit

class ExtraGuessPopupView: UIView {

    @IBOutlet weak var countdownLabel: UILabel!
    
    var countdownValue = 5
    var countdownTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        restartCountdown()
    }
    
    func setupUI() {
        // Configure the appearance of the popup view and countdownLabel
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
        }
    }
    
    func hidePopup() {
        countdownTimer?.invalidate()
        
        // Animate the popup view out of sight
        self.isHidden = true
    }
    
    @IBAction func noThanksButtonClicked(_ sender: UIButton) {
        hidePopup()
    }

}
