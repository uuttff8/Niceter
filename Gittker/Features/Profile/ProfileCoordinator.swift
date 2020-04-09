//
//  ProfileCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ProfileCoordinator: Coordinator {
    var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: ProfileViewController?
    var username: String
    
    init(with navigationController: ASNavigationController?, username: String) {
        self.navigationController = navigationController
        self.username = username
        
        currentController = ProfileViewController(coordinator: self, username: username)
        childCoordinators.append(self)
    }
    
    func start() {
        self.navigationController?.pushViewController(currentController!, animated: true)
    }

}
