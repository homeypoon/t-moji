//
//  SearchBarReusableView.swift
//  T-moji
//
//  Created by Homey Poon on 2023-08-16.
//

import UIKit

class SearchBarReusableView: UICollectionReusableView {
    static let reuseIdentifier = "SearchBar"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    
    let searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.tintColor = UIColor.black.withAlphaComponent(1.0)
        searchBar.placeholder = "Search for User"
        searchBar.backgroundColor = UIColor.clear
        searchBar.barTintColor = UIColor.clear
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false
        searchBar.sizeToFit()
        
        return searchBar
    }()
    
    private func setUpView() {
        
        addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
}
