//
//  MainTabBarCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()

    var currentController: MainTabBarController?
    var userdata: User

    init(navigationController: UINavigationController?, with user: User) {
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
