//
//  RoomChatCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomChatCoordinator: Coordinator {
    enum RoomChatControllerFlow {
        case full
        case preview
    }

    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    var currentController: RoomChatViewController?
    let currentFlow: RoomChatCoordinator.RoomChatControllerFlow
    
    private var roomSchema: RoomSchema
    private var isJoined: Bool
    
    init(with navigationController: ASNavigationController?, roomSchema: RoomSchema, isJoined: Bool, flow: RoomChatControllerFlow) {
        self.navigationController = navigationController
        self.isJoined = isJoined
        self.roomSchema = roomSchema
        self.currentFlow = flow
        
        currentController = RoomChatViewController(coordinator: self, roomSchema: roomSchema, isJoined: isJoined)
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showProfileScreen(username: String) {
        let coord = ProfileCoordinator(with: navigationController, username: username, flow: ProfileCoordinator.ProfileFlow.fromSearch)
        childCoordinators.append(coord)
        coord.start()
    }
    
    func showRoomInfoScreen(roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        let coord = RoomInfoCoordinator(with: self.navigationController!,
                                        roomSchema: roomSchema,
                                        prefetchedUsers: prefetchedUsers)
        self.childCoordinators.append(coord)
        coord.start()
    }
}
