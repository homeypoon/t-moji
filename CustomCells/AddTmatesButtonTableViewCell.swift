//
//  AddTmatesButtomTableViewCell.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-16.
//
import UIKit

protocol AddTmatesButtonTableViewCellDelegate: AnyObject {
    func addTmatesButtonTapped()
}

class AddTmatesButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var addTmatesButton: UIButton!
    
    weak var delegate: AddTmatesButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTmatesButton.addTarget(self, action: #selector(addTmatesButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addTmatesButtonTapped() {
        delegate?.addTmatesButtonTapped()
    }
}
