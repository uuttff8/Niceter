//
//  HomeSearchBar.swift
//  Gittker
//
//  Created by uuttff8 on 3/20/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeSearchBar: UISearchBar {
    let placeholderWidth: CGFloat = 340 // Replace with whatever value works for your placeholder text
    var offset = UIOffset()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        let width = UIScreen.main.bounds.width
        
        offset = UIOffset(horizontal: width - placeholderWidth, vertical: 0)
        self.setPositionAdjustment(offset, for: .search)
        self.configureSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureSearchBar() {
        placeholder = "Search for rooms or groups"
        
    }
}

extension HomeSearchBar: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let noOffset = UIOffset(horizontal: 0, vertical: 0)
        searchBar.setPositionAdjustment(noOffset, for: .search)
        
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setPositionAdjustment(offset, for: .search)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
}
