//
//  PeopleCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class PeopleCoordinator: Coordinator {

    var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: PeopleViewController?

    init(with navigationController: ASNavigationController?) {
        self.navigationController = navigationController
        
        currentController = PeopleViewController(coordinator: self)
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
    
    func showSuggestedRoom(with rooms: Array<RoomSchema>?, currentlyJoinedRooms: [RoomSchema]) {
        self.currentController?.view = SuggestedRoomsCoordinator(
            with: navigationController,
            rooms: rooms,
            currentlyJoinedRooms: currentlyJoinedRooms
        ).currentController?.view
    }
}
