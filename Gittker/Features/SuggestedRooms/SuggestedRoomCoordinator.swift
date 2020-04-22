//
//  SuggestedRoomCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsCoordinator: Coordinator {
    enum SuggestedFlow {
        case chat
        case user
    }
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: SuggestedRoomsNode?
    var rooms: Array<RoomSchema>?
    var currentFlow: SuggestedFlow
    
    init(with navigationController: ASNavigationController?, rooms: Array<RoomSchema>?, currentlyJoinedRooms: [RoomSchema], flow: SuggestedFlow) {
        self.navigationController = navigationController
        self.rooms = rooms
        self.currentFlow = flow
        
        currentController = SuggestedRoomsNode(rooms: rooms, coordinator: self, currentlyJoinedRooms: currentlyJoinedRooms)
        currentController?.coordinator = self
        childCoordinators.append(self)
    }
    
    func start() {
//        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showChat(roomSchema: RoomSchema, isJoined: Bool) {
        switch currentFlow {
        case .chat:
            let coord = RoomChatCoordinator(with: navigationController, roomSchema: roomSchema, isJoined: isJoined)
            childCoordinators.append(coord)
            coord.start()
        case .user:
            let coord = UserChatCoordinator(with: navigationController, roomSchema: roomSchema.toIntermediate(isUser: true), isJoined: isJoined)
            childCoordinators.append(coord)
            coord.start()
        }
    }
}
