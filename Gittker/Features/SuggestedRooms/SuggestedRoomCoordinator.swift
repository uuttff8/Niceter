//
//  SuggestedRoomCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsCoordinator: Coordinator {

    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: SuggestedRoomsNode?
    
    var rooms: Array<RoomSchema>?
    
    init(with navigationController: ASNavigationController?, rooms: Array<RoomSchema>?) {
        self.navigationController = navigationController
        self.rooms = rooms
        
        currentController = SuggestedRoomsNode(rooms: rooms, coordinator: self)
        currentController?.coordinator = self
        childCoordinators.append(self)
    }
    
    func start() {
//        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showChat(roomId: String) {
        let coord = RoomChatCoordinator(with: navigationController, roomId: roomId)
        coord.start()
    }
}

