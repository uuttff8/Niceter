//
//  HomeViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsViewModel {
    weak var dataSource : GenericDataSource<RoomSchema>?
    
    var suggestedRoomsData: Array<RoomSchema>?
    
    init(dataSource : GenericDataSource<RoomSchema>?) {
        self.dataSource = dataSource
    }
    
    func fetchRooms() {
        CachedRoomLoader.init(cacheKey: Config.CacheKeys.roomsKey)
            .fetchNewAndCache { (rooms) in
                self.dataSource?.data.value = rooms.filterByChats().sortByUnreadAndLastAccess()
        }
    }
    
    func fetchRoomsCached() {
        CachedRoomLoader.init(cacheKey: Config.CacheKeys.roomsKey)
            .fetchData { (rooms) in
                self.dataSource?.data.value = rooms.filterByChats().sortByUnreadAndLastAccess()
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
}

class RoomsDataSource: GenericDataSource<RoomSchema>, ASTableDataSource {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let userId = ShareData().userdata?.id else { return }
            let room = data.value[indexPath.row]
            
            data.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            leaveFromRoom(roomId: room.id, userId: userId) { (suc) in
                print(suc)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func leaveFromRoom(roomId: String, userId: String, completion: @escaping (SuccessSchema) -> Void) {
        GitterApi.shared.removeUserFromRoom(userId: userId, roomId: roomId) { (res) in
            completion(res)
        }
    }
}

// MARK: - TableView Delegate
class RoomsTableViewDelegate: NSObject, ASTableDelegate {
    var dataSource: [RoomSchema]?
    weak var coordinator: RoomsCoordinator?
    
    private var vc: UIViewController
    
    init(with vc: UIViewController) {
        self.vc = vc
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if let room = dataSource?[indexPath.item] {
            coordinator?.showChat(roomSchema: room)
        }
        tableNode.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let room = dataSource?[indexPath.row] else { return nil }
        
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
}
