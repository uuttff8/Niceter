//
//  SuggestedRoomsViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsViewModel {
    weak var dataSource : GenericDataSource<SuggestedRoomContent>?
    private var rooms: Array<SuggestedRoomContent>?
    
    init(dataSource : GenericDataSource<SuggestedRoomContent>?, rooms: Array<SuggestedRoomContent>?) {
        self.dataSource = dataSource
        self.rooms = rooms
    }
    
    func fetchRooms() {
        self.dataSource?.data.value = rooms ?? []
    }
}

class SuggestedRoomsDataSource: GenericDataSource<SuggestedRoomContent>, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        data.value.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let room = self.data.value[indexPath.row]
            let cell = SuggestemRoomTableNode(with: room)
            
            return cell
        }
    }
}

class SuggestedRoomsTableNodeDelegate: NSObject, ASTableDelegate {
    init(dataSource: [SuggestedRoomContent], currentlyJoinedRooms: [RoomSchema], coordinator: SuggestedRoomsCoordinator?) {
        self.dataSource = dataSource
        self.currentlyJoinedRooms = currentlyJoinedRooms
        self.coordinator = coordinator
    }
    
    var dataSource: [SuggestedRoomContent]
    var currentlyJoinedRooms: [RoomSchema]
    weak var coordinator: SuggestedRoomsCoordinator?
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        var isJoined = false
        
        let roomId = dataSource[indexPath.item].roomId
        
        if let _ = currentlyJoinedRooms.firstIndex(where: { $0.id == roomId }) {
            isJoined = true
        }
        
        coordinator?.showChat(roomId: roomId, isJoined: isJoined)
        
        tableNode.deselectRow(at: indexPath, animated: true)
    }
}
