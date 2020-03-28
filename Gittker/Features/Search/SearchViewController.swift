//
//  SearchViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, Storyboarded {
    
    weak var coordinator: SearchCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

//// MARK: - Searching
//extension SearchViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        // If the search bar contains text, filter our data with the string
//        if let searchText = searchController.searchBar.text {
////            filterContent(for: searchText)
//            // Reload the table view with the search result data.
//            tableView.reloadData()
//        }
//    }
//    
////    func filterContent(for searchText: String) {
////        // Update the searchResults array with matches
////        // in our entries based on the title value.
////        searchResults = entries.filter({ (title: String, image: String) -> Bool in
////            let match = title.range(of: searchText, options: .caseInsensitive)
////            // Return the tuple if the range contains a match.
////            return match != nil
////        })
////    }
//}
