//
//  HomeViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsViewModel {
    weak var dataSource : GenericDataSource<RoomSchema>?
    
    var updateFirstly: (() -> Void)?
    
    var suggestedRoomsData: Array<RoomSchema>?
    
    init(dataSource : GenericDataSource<RoomSchema>?) {
        self.dataSource = dataSource
    }
    
    func numberOfFavourites() -> Int {
        var index = 0
        dataSource?.data.value.forEach({ (room) in
            if room.favourite != nil {
                index += 1
            }
        })
        return index
    }
    
    func fetchRooms(completion: @escaping ([RoomSchema]) -> Void) {
        CachedRoomLoader.init(cacheKey: Config.CacheKeys.roomsKey)
            .fetchNewAndCache { (rooms) in // fetch new here and cache
                let filteredRooms = rooms.filterByChats().sortByUnreadAndFavourite()
                ShareData().currentlyJoinedChats = filteredRooms
                DispatchQueue.main.async {
                    completion(filteredRooms)
                }
        }
    }
    
    func fetchRoomsCached() {
        CachedRoomLoader.init(cacheKey: Config.CacheKeys.roomsKey)
            .fetchData { (rooms) in // return cached values first, then from networking
                let filteredRooms = rooms.filterByChats().sortByUnreadAndFavourite()
                self.dataSource?.data.value = filteredRooms
                ShareData().currentlyJoinedChats = filteredRooms
                self.updateFirstly?()
        }
    }
    
    func fetchSuggestedRooms() {
        CachedSuggestedRoomLoader.init(cacheKey: Config.CacheKeys.suggestedRoomsKey)
            .fetchData { (rooms) in
                self.suggestedRoomsData = rooms
        }
    }
    
    func suggestedRoomsSearchQuery(with text: String, completion: @escaping (([RoomSchema]) -> Void)) {
        GitterApi.shared.searchRooms(query: text) { (result) in
            completion(result!.results)
        }
    }
    
    func leaveFromRoom(roomId: String, userId: String, completion: @escaping (SuccessSchema) -> Void) {
        GitterApi.shared.removeUserFromRoom(userId: userId, roomId: roomId) { (res) in
            completion(res)
        }
    }
    
    func markAllMessagesAsRead(roomId: String, userId: String) {
        GitterApi.shared.markAllMessagesAsRead(roomId: roomId, userId: userId) { (_) in
            
        }
    }
}


// MARK: - TableView Delegate
class RoomsTableViewManager: GenericDataSource<RoomSchema>, ASTableDelegate, ASTableDataSource {
    weak var coordinator: RoomsCoordinator?
    
    private var vc: UIViewController
    
    init(with vc: UIViewController) {
        self.vc = vc
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        data.value.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let room = self.data.value[indexPath.row]
            let cell = RoomTableNode(with: RoomTableNode.Content(avatarUrl: room.avatarUrl ?? "",
                                                                 title: room.name ?? "",
                                                                 subtitle: room.topic ?? "",
                                                                 unreadItems: room.unreadItems ?? 0))
            
            return cell
        }
    }
        
    func leaveFromRoom(roomId: String, userId: String, completion: @escaping (SuccessSchema) -> Void) {
        GitterApi.shared.removeUserFromRoom(userId: userId, roomId: roomId) { (res) in
            completion(res)
        }
    }
    
    func markAllMessagesAsRead(roomId: String, userId: String) {
        GitterApi.shared.markAllMessagesAsRead(roomId: roomId, userId: userId) { (_) in
            
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let room = data.value[indexPath.item]
        coordinator?.showChat(roomSchema: room)
        tableNode.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let room = data.value[indexPath.row] 
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            return self.coordinator!.previewChat(roomSchema: room)
        }) { _ -> UIMenu? in
            let action = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                RoomsService.share(room: room, in: self.vc)
            }
            return UIMenu(title: "", children: [action])
        }
        return configuration
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized()) { (_, _, completion) in
            guard let userId = ShareData().userdata?.id else { return }
            let room = self.data.value[indexPath.row]
            
            self.leaveFromRoom(roomId: room.id, userId: userId) { (suc) in
                print(suc)
            }
            
            self.data.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let readMessagesAction = UIContextualAction(style: .normal, title: "Read".localized()) { (_, _, completion) in
            guard let userId = ShareData().userdata?.id else { return }
            let room = self.data.value[indexPath.row]
            
            self.markAllMessagesAsRead(roomId: room.id, userId: userId)
            
            completion(true)
        }
        
        readMessagesAction.image = UIImage(systemName: "envelope.open")
        readMessagesAction.backgroundColor = UIColor.systemBlue
        
        return UISwipeActionsConfiguration(actions: [readMessagesAction])

    }
}
