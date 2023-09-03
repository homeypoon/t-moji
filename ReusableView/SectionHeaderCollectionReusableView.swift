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


class TmateHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = "TmateHeader"
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
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
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(pointsLabel)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ])
    }
    
    func configure(username: String, points: String, isCurrentUser: Bool) {
        usernameLabel.text = username
        pointsLabel.text = points
        
        if isCurrentUser {
            usernameLabel.text = "Me"
            usernameLabel.textColor = UIColor(named: "darkCurrentUserText")
            usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        } else {
            print("not current")
            usernameLabel.text = username
            usernameLabel.applyStyle(labelType: .otherUser)
        }
    }
}
