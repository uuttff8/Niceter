//
//  HomeViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Storyboarded {

    weak var coordinator: HomeCoordinator? {
        didSet {
            guard let _ = self.coordinator else { print("HomeCoordinator is not loaded"); return }
        }
    }
    
    private let dataSource = HomeDataSource()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(withClass: TitleSubtitleTableViewCell.self)
        }
    }
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel(dataSource: self.dataSource)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Conversations"
        
        self.tableView.dataSource = self.dataSource
        
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        self.viewModel.fetchRooms()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
