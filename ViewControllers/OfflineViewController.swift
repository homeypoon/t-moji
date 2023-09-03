//
//  OfflineViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-09-02.
//

import UIKit

class OfflineViewController: UIViewController {
    var isOffline: Bool = true
    
    @objc func networkStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool, isConnected {

            print("offline")
            isOffline = false
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        } else {
            isOffline = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: Notification.Name("NetworkStatusChanged"), object: nil)
    }
    
    @IBAction func tryAgainClicked(_ sender: UIButton) {
    }

}
