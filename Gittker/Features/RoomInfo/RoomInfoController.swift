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
    private let prefetchedUsers: [UserSchema]
    
    private var tableNode: ASTableNode {
        return node
    }
    
    init(coordinator: RoomInfoCoordinator, roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.prefetchedUsers = prefetchedUsers
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
        
        self.viewModel.updateTableNode = { [unowned self] (newList) in
            let newIndexpaths =
                Array(((self.viewModel.roomSchemaPeople.count - 1) - (newList.count - 1) - 1) ..< self.viewModel.roomSchemaPeople.count - 1)
                    .map { (index) in
                        IndexPath(row: index, section: 2)
            }
            
            self.tableNode.performBatchUpdates({
                self.tableNode.insertRows(at: newIndexpaths, with: .automatic)
            }, completion: nil)
        }
        
        setupTableNodeData(prefetchedUsers: self.prefetchedUsers) {
            self.viewModel.loadMorePeople() { }
        }
    }
    
    private func setupTableNodeData(prefetchedUsers: [UserSchema], completion: @escaping (() -> Void)) {
        // if no data from room chat was loaded, then load it (first 30)
        if prefetchedUsers.isEmpty {
            CachedPrefetchRoomUsers(cacheKey: Config.CacheKeys.roomUsers(roomId: self.roomSchema.id), roomId: self.roomSchema.id)
                .fetchNewAndCache { (usersSchema) in
                    self.viewModel.roomSchemaPeople = usersSchema
                    self.loadFirstElementsFromNet(newUsers: usersSchema)
                    
                    // if loaded users less than, it is bad idea to load more users
                    if usersSchema.count >= 30 {
                        completion()
                    }
            }
        } else { // else loading new people
            completion()
        }
    }
    
    private func loadFirstElementsFromNet(newUsers: [UserSchema]) {
        let newIndexpaths = Array(0 ..< newUsers.count) .map { (index) in
            IndexPath(row: index, section: 2)
        }
        
        self.tableNode.performBatchUpdates({
            self.tableNode.insertRows(at: newIndexpaths, with: .automatic)
        }, completion: nil)
    }
}
