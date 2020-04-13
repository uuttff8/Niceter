//
//  CreateRoomViewController.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomViewController: ASViewController<ASTableNode> {
    weak var coordinator: CreateRoomCoordinator?
    
    lazy var viewModel: CreateRoomViewModel = CreateRoomViewModel(dataSource: self.tableDelegates)
    
    private lazy var tableDelegates = CreateRoomTableDelegates(with: self.coordinator!)
    private var tableNode: ASTableNode {
        return node
    }
    
    init(coordinator: CreateRoomCoordinator) {
        self.coordinator = coordinator
        super.init(node: ASTableNode(style: .grouped))
        self.tableNode.dataSource = self.tableDelegates
        self.tableNode.delegate = self.tableDelegates
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Room"
        setupNavigationControllerButtons()
        
        self.tableDelegates.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableNode.reloadData()
            }
        }
        
        self.viewModel.fetchDataSource()
    }
    
    private func setupNavigationControllerButtons() {
        let doneButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(doneButtonAction(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneButtonAction(_ sender: Any) {
        print("123123")
        self.dismiss(animated: true, completion: nil)
    }
}
