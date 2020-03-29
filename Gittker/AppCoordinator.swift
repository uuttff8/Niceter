//
//  AppCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class AppCoordinator: Coordinator {
    private(set) var window: UIWindow

    var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        start()
    }

    func start() {
        if let userdata = LoginData.shared.getCurrentUser() {
            let tabBar = MainTabBarCoordinator(navigationController: nil, with: userdata)
            window.rootViewController = tabBar.currentController
            childCoordinators.append(tabBar)
            tabBar.start()
        } else {
            let root = ASNavigationController()
            window.rootViewController = root
            root.setNavigationBarHidden(true, animated: false)
            let child = LoginAuthCoordinator(navigationController: root)
            childCoordinators.append(child)
            child.start()
        }
    }
}
