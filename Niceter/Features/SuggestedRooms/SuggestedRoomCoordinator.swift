//
//  SuggestedRoomCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsCoordinator: Coordinator {
    enum Flow {
        case chat
        case user
    }
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    var currentlyJoinedRooms: [RoomSchema]
    
    var currentController: SuggestedRoomsNode?
    var rooms: Array<RoomSchema>?
    var currentFlow: Flow
    
    init(
        with navigationController: ASNavigationController?,
        rooms: Array<RoomSchema>?,
        currentlyJoinedRooms: [RoomSchema],
        flow: Flow
    ) {
        self.navigationController = navigationController
        self.rooms = rooms
        self.currentFlow = flow
        self.currentlyJoinedRooms = currentlyJoinedRooms
    }
    
    func start() {
        self.currentController = SuggestedRoomsNode(rooms: rooms,
                                               coordinator: self,
                                               currentlyJoinedRooms: currentlyJoinedRooms)
//        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showChat(roomSchema: RoomSchema, isJoined: Bool) {
        switch currentFlow {
        case .chat:
            let coord = RoomChatCoordinator(with: navigationController,
                                            roomSchema: roomSchema,
                                            isJoined: isJoined,
                                            flow: .full)
            childCoordinators.append(coord)
            coord.start()
        case .user:
            let coord = UserChatCoordinator(with: navigationController,
                                            roomSchema: roomSchema.toIntermediate(isUser: true),
                                            isJoined: isJoined,
                                            flow: .full)
            childCoordinators.append(coord)
            coord.start()
        }
    }
}
