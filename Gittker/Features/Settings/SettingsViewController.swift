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
    
    lazy var viewModel: SettingsViewModel = SettingsViewModel(dataSource: self.tableDelegates)
    
    private let tableDelegates = SettingsTableDelegates()
    private var tableNode: ASTableNode {
        return node
    }

    init(coordinator: SettingsCoordinator) {
        super.init(node: ASTableNode(style: .insetGrouped))
        self.tableNode.dataSource = self.tableDelegates
        self.tableNode.delegate = self.tableDelegates
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        self.tableDelegates.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableNode.reloadData()
            }
        }
        
        self.viewModel.fetchDataSource()
    }
    
}

