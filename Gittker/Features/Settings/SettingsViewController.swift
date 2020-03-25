//
//  CommunitiesViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SettingsViewController: ASViewController<ASTableNode> {
    
    weak var coordinator: SettingsCoordinator?
    
    lazy var viewModel: SettingsViewModel = SettingsViewModel(dataSource: self.dataSource)
    
    private let dataSource = SettingsDataSource()
    private var tableNode: ASTableNode {
        return node
    }

    init(coordinator: SettingsCoordinator) {
        super.init(node: ASTableNode(style: .insetGrouped))
//        node.backgroundColor = .systemBackground
//        self.tableNode.view.separatorStyle = .none
        
        self.tableNode.dataSource = self.dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableNode.reloadData()
            }
        }
        
        self.viewModel.fetchDataSource()
    }
    
}

