//
//  HelperClass.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-08.
//

import Foundation
import UIKit

struct Helper {
    static func presentErrorAlert(on viewController: UIViewController, with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
