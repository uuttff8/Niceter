//
//  ProfileCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ProfileCoordinator: Coordinator {
    enum ProfileFlow {
        case fromChat
        case fromSearch
    }
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: ProfileViewController?
    var username: String
    var currentFlow: ProfileFlow
    
    init(with navigationController: ASNavigationController?, username: String, flow: ProfileFlow) {
        self.navigationController = navigationController
        self.username = username
        self.currentFlow = flow
        
        currentController = ProfileViewController(coordinator: self, username: username)
        childCoordinators.append(self)
    }
    
    func start() {
        
        guard let vc = currentController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChat(intermediate: UserRoomIntermediate, isJoined: Bool) {
        let coord = UserChatCoordinator(with: navigationController,
                                        roomSchema: intermediate,
                                        isJoined: isJoined,
                                        flow: .full)
        childCoordinators.append(coord)
        coord.start()
    }
}
