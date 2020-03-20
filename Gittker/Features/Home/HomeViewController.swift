//
//  HomeViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Storyboarded {
    
    let searchBar: HomeSearchBar = {
        let bar = HomeSearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44.0))
        return bar
    }()
    
    weak var coordinator: HomeCoordinator? {
        didSet {
            guard let _ = self.coordinator else { print("HomeCoordinator is not loaded"); return }
        }
    }
    
    private let dataSource = HomeDataSource()
    private var tableDelegate = HomeTableViewDelegate()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableDelegate.coordinator = self.coordinator
            
            tableView.delegate = self.tableDelegate
            tableView.dataSource = self.dataSource
            tableView.registerNib(withClass: RoomTableViewCell.self)
            
            tableView.estimatedRowHeight = 71
            tableView.rowHeight = UITableView.automaticDimension
            
            tableView.tableHeaderView = searchBar
            tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel(dataSource: self.dataSource)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rooms"
        
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableDelegate.dataSource = self.dataSource.data.value
                self.tableView.reloadData()
            }
        }
        
        self.viewModel.fetchRoomsCached()
    }
}
