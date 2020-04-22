//
//  UserChatCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class UserChatCoordinator: Coordinator {

    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: UserChatViewController?
    var roomSchema: UserRoomIntermediate
    var isJoined: Bool
    
    init(with navigationController: ASNavigationController?, roomSchema: UserRoomIntermediate, isJoined: Bool) {
        self.navigationController = navigationController
        self.isJoined = isJoined
        self.roomSchema = roomSchema
        print(roomSchema)
        currentController = UserChatViewController(coordinator: self, intermediate: roomSchema, isJoined: isJoined)
    }
    
    func start() {
        guard let vc = currentController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfileScreen(username: String) {
        let coord = ProfileCoordinator(with: navigationController, username: username, flow: ProfileCoordinator.ProfileFlow.fromSearch)
        childCoordinators.append(coord)
        coord.start()
    }
}
