//
//  SuggestedRoomsNodeController.swift
//  Niceter
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsNode: ASDisplayNode {
    weak var coordinator: SuggestedRoomsCoordinator?
    
    // MARK: - Variables
    let contentNode: ASTableNode
    
    private let dataSource = SuggestedRoomsDataSource()
    private lazy var tableDelegate = SuggestedRoomsTableNodeDelegate(dataSource: self.dataSource.data.value,
                                                                     currentlyJoinedRooms: self.currentlyJoinedRooms,
                                                                     coordinator: self.coordinator)
    private let currentlyJoinedRooms: [RoomSchema]
    
    var viewModel: SuggestedRoomsViewModel
    
    init(rooms: Array<RoomSchema>?, coordinator: SuggestedRoomsCoordinator?, currentlyJoinedRooms: [RoomSchema]) {
        contentNode = ASTableNode(style: .plain)
        self.coordinator = coordinator
        self.currentlyJoinedRooms = currentlyJoinedRooms
        
        viewModel = SuggestedRoomsViewModel(dataSource: self.dataSource, rooms: rooms)
        
        super.init()
        
        // WTF WHY IS IT WORK
        self.addSubnode(self.contentNode)
        self.addSubnode(self.contentNode)

        setupTableNode()
    }
    
    private func setupTableNode() {
        contentNode.delegate = self.tableDelegate
        contentNode.dataSource = self.dataSource
        
        contentNode.view.separatorStyle = .none
        contentNode.view.keyboardDismissMode = .onDrag
    }
        
    override func didLoad() {
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableDelegate.dataSource = self.dataSource.data.value
                self.contentNode.reloadData()
            }
        }
        
        self.viewModel.fetchRooms()
    }
    
    override func didExitDisplayState() {
        coordinator?.removeDependency(coordinator)
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.contentNode)
    }
}
