//
//  UserChatCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class UserChatCoordinator: Coordinator {
    enum UserChatControllerFlow {
        case full
        case preview
    }
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: UserChatViewController?
    private var roomSchema: UserRoomIntermediate
    private var isJoined: Bool
    var currentFlow: UserChatControllerFlow
    
    
    init(with navigationController: ASNavigationController?, roomSchema: UserRoomIntermediate, isJoined: Bool, flow: UserChatControllerFlow) {
        self.navigationController = navigationController
        self.isJoined = isJoined
        self.roomSchema = roomSchema
        self.currentFlow = flow
        
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
