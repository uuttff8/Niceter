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
    
    init(coordinator: RoomInfoCoordinator, roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.viewModel = RoomInfoViewModel(coordinator: coordinator,
                                           roomSchema: roomSchema,
                                           prefetchedUsers: prefetchedUsers)
        super.init(node: ASTableNode(style: .grouped))
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.delegate = viewModel
        self.tableNode.dataSource = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = roomSchema.name
        
                
        self.viewModel.updateTableNode = { [unowned self] newList in
            
            let newIndexpaths =
                Array(((self.viewModel.roomSchemaPeople.count - 1) - (newList.count - 1) - 1) ..< self.viewModel.roomSchemaPeople.count - 1)
                    .map { (index) in
                        IndexPath(row: index, section: 2)
            }
            
            self.tableNode.performBatchUpdates({
                self.tableNode.insertRows(at: newIndexpaths, with: .automatic)
            }, completion: nil)
        }
        
        self.viewModel.loadMorePeople()
    }
}
