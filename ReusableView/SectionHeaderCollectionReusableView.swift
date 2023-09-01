//
//  SectionHeaderCollectionReusableView.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-12.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeader"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ])
    }
    
    
    func configure(title: String, colorName: String) {
        titleLabel.text = title
        titleLabel.textColor = UIColor(named: colorName)
    }
    
    func configureBigHeader(title: String, colorName: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(named: colorName)
    }
}
