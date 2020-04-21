//
//  SuggestedRoomsViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsViewModel {
    weak var dataSource : GenericDataSource<RoomSchema>?
    private var rooms: Array<RoomSchema>?
    
    init(dataSource : GenericDataSource<RoomSchema>?, rooms: Array<RoomSchema>?) {
        self.dataSource = dataSource
        self.rooms = rooms
    }
    
    func fetchRooms() {
        self.dataSource?.data.value = rooms ?? []
    }
}

class SuggestedRoomsDataSource: GenericDataSource<RoomSchema>, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        data.value.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let room = self.data.value[indexPath.row]
            let cell = SuggestedRoomTableNode(with: SuggestedRoomTableNode.Content(title: room.name ?? "",
                                                                                   avatarUrl: room.avatarUrl ?? "",
                                                                                   roomId: room.id))
            
            return cell
        }
    }
}

class SuggestedRoomsTableNodeDelegate: NSObject, ASTableDelegate {
    init(dataSource: [RoomSchema], currentlyJoinedRooms: [RoomSchema], coordinator: SuggestedRoomsCoordinator?) {
        self.dataSource = dataSource
        self.currentlyJoinedRooms = currentlyJoinedRooms
        self.coordinator = coordinator
    }
    
    var dataSource: [RoomSchema]
    var currentlyJoinedRooms: [RoomSchema]
    weak var coordinator: SuggestedRoomsCoordinator?
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        var room = dataSource[indexPath.item]

        var isJoined = false
        switch coordinator?.currentFlow {
        case .chat:
            
            if let _ = currentlyJoinedRooms.firstIndex(where: { $0.id == room.id }) {
                isJoined = true
            }
        case .user:
            guard let users = ShareData().currentlyJoinedUsers else { return }
            
            if let index = users.firstIndex(where: { $0.url == room.url }) {
                isJoined = true
                room.id = users[index].id // user id is not equal to room id 
            }
        default: break
        }
        
        
        coordinator?.showChat(roomSchema: room, isJoined: isJoined)
        
        tableNode.deselectRow(at: indexPath, animated: true)
    }
}
