//
//  HomeViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class HomeViewModel {
    weak var dataSource : GenericDataSource<RoomSchema>?
    
    init(dataSource : GenericDataSource<RoomSchema>?) {
        self.dataSource = dataSource
    }
    
    func fetchRoomsCached() {
        CachedRoomLoader.init(cacheKey: Config.CacheKeys.roomsKey)
            .loadRooms { (rooms) in
                self.dataSource?.data.value = rooms
        }
    }
}

class HomeDataSource: GenericDataSource<RoomSchema>, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        data.value.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let room = self.data.value[indexPath.row]
            let cell = RoomTableNode(with: RoomContent(avatarUrl: room.avatarUrl ?? "", title: room.name, subtitle: room.topic ?? ""))
            
            return cell
        }
    }
}


class HomeTableViewDelegate: NSObject, ASTableDelegate {
    var dataSource: [RoomSchema]?
    weak var coordinator: HomeCoordinator?
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if let roomId = dataSource?[indexPath.item].id {
            coordinator?.showChat(roomId: roomId)
        }
        tableNode.deselectRow(at: indexPath, animated: true)
    }
}
