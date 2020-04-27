//
//  MainTabBarCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

final class MainTabBarCoordinator: Coordinator {
    var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()

    var currentController: MainTabBarController?
    var userdata: UserSchema

    init(navigationController: ASNavigationController?, with user: UserSchema) {
        self.navigationController = navigationController
        self.userdata = user
        
        self.currentController = MainTabBarController(with: user)
        self.childCoordinators.append(self)
        currentController?.coordinator = self
    }
    
    func start() {
        navigationController?.pushViewController(currentController ?? UIViewController(),
                                                 animated: true)

    }
}
