//
//  RoomsCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsCoordinator: Coordinator {
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: RoomsViewController?
    
    var userdata: UserSchema
    
    init(with navigationController: ASNavigationController?, user: UserSchema) {
        self.navigationController = navigationController
        self.userdata = user
        
        currentController = RoomsViewController(coordinator: self)
        childCoordinators.append(self)
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showChat(roomSchema: RoomSchema) {
        let coord = RoomChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema,
                                        isJoined: true)
        coord.start()
    }
    
    func previewChat(roomSchema: RoomSchema) -> RoomChatViewController {
        let coord = RoomChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema,
                                        isJoined: true)
        childCoordinators.append(coord)
        return coord.currentController!
    }
    
    func showSuggestedRoom(with rooms: Array<RoomSchema>?, currentlyJoinedRooms: [RoomSchema]) {
        self.currentController?.view = SuggestedRoomsCoordinator(
            with: navigationController,
            rooms: rooms,
            currentlyJoinedRooms: currentlyJoinedRooms,
            flow: SuggestedRoomsCoordinator.SuggestedFlow.chat
        ).currentController?.view
    }
    
    func showCreateRoom() {
        let coord = CreateRoomCoordinator(with: navigationController)
        childCoordinators.append(coord)
        coord.start()
    }
}
