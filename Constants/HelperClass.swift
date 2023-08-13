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
    
    static func presentLoading(on viewController: UIViewController, with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func timeSinceUserCompleteTime(from userCompleteTime: Date) -> String {
        let calendar = Calendar.current
        
        // Get the current date and time
        let currentDate = Date()
        
        // Calculate the time difference between userCompleteTime and the current time
        let timeDifference = calendar.dateComponents([.day, .hour, .minute], from: userCompleteTime, to: currentDate)
        
        if let days = timeDifference.day, days >= 1 {
            // If it has been at least 24 hours, show the amount of days past
            if days >= 2 {
                return "~ \(days) days"
            } else {
                return "~ \(days) day"
            }
        } else if let hours = timeDifference.hour, hours >= 1 {
            // If it has been at least 1 hour, show the amount of hours past
            if hours >= 2 {
                return "~ \(hours) hours"
            } else {
                return "~ \(hours) hour"
            }
        } else if let minutes = timeDifference.minute, minutes >= 1 {
            // If it has been at least 1 minute, show the amount of minutes past
            if minutes >= 2 {
                return "~ \(minutes) minutes"
            } else {
                return "~ \(minutes) minute"
            }
        } else {
            // Otherwise, show "Less than a minute"
            return "~ Less than a minute"
        }
    }

}
