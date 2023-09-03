//
//  SettingsTableViewController.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//


import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: Notification.Name("NetworkStatusChanged"), object: nil)
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool, !isConnected {
            // The app is offline, present the OfflineViewController

            DispatchQueue.main.async {
                let offlineVC = self.storyboard?.instantiateViewController(withIdentifier: "OfflineViewController") as! OfflineViewController
                offlineVC.modalPresentationStyle = .fullScreen
                self.present(offlineVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
            do {
              try Auth.auth().signOut()
            } catch let signOutError as NSError {
                self.presentErrorAlert(with: signOutError.localizedDescription)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              return
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    

}
