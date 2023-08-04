//
//  EmojiTextField.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-01.
//

import Foundation
import UIKit

class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}
