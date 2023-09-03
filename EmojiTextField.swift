//
//  EmojiTextField.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-01.
//

import Foundation
import UIKit

class EmojiTextField: RoundedTextField {
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}

class RoundedTextField: UITextField {
    var textPadding = UIEdgeInsets(
        top: 8,
        left: 16,
        bottom: 8,
        right: 8
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.masksToBounds = false
        layer.borderColor = UIColor.clear.cgColor
        
        layer.shadowColor = UIColor(named: "primaryShadow")?.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0.4, height: 0.6)
        layer.shadowRadius = 1.5
    }
}
