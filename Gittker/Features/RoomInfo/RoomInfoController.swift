//
//  RoomInfoController.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoController: ASViewController<ASTableNode> {
    weak var coordinator: RoomInfoCoordinator?
    let viewModel: RoomInfoViewModel
    
    private let roomSchema: RoomSchema
    
    private var tableNode: ASTableNode {
        return node
    }
    
    init(coordinator: RoomInfoCoordinator, roomSchema: RoomSchema) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.viewModel = RoomInfoViewModel(roomSchema: roomSchema)
        super.init(node: ASTableNode(style: .grouped))
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableNode.delegate = viewModel
        self.tableNode.dataSource = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = roomSchema.name
    }
}
