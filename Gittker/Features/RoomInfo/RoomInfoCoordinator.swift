//
//  RoomInfoCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoCoordinator: Coordinator {
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: RoomInfoController?
    var prefetchedUsers: [UserSchema]
    
    init(with navigation: ASNavigationController, roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        self.navigationController = navigation
        self.prefetchedUsers = prefetchedUsers
        
        self.currentController = RoomInfoController(coordinator: self, roomSchema: roomSchema, prefetchedUsers: prefetchedUsers)
    }
    
    func start() {
        guard let navigation = navigationController else { return }
        
        navigation.pushViewController(currentController!, animated: true)
    }
    
    func showProfileScreen(username: String) {
        let coord = ProfileCoordinator(with: navigationController, username: username, flow: ProfileCoordinator.ProfileFlow.fromChat)
        childCoordinators.append(coord)
        coord.start()
    }
}
