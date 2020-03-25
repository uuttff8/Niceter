//
//  SuggestedRoomCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class SuggestedRoomsCoordinator: Coordinator {

    weak var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: SuggestedRoomsNodeController?
    
    var room: Array<RoomSchema>?
    
    init(with navigationController: UINavigationController?, room: Array<RoomSchema>?) {
        self.navigationController = navigationController
        self.room = room
        
        currentController = SuggestedRoomsNodeController(rooms: room, coordinator: self)
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

