//
//  AppCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    private(set) var window: UIWindow

    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        start()
    }

    func start() {
        if let userdata = LoginData.shared.getCurrentUser() {
            let tabBar = MainTabBarCoordinator(navigationController: nil, with: userdata)
            childCoordinators.append(tabBar)
            window.rootViewController = tabBar.currentController
            tabBar.start()
        } else {
            let root = UINavigationController()
            root.setNavigationBarHidden(true, animated: false)
            let child = LoginAuthCoordinator(navigationController: root)
            childCoordinators.append(child)
            window.rootViewController = root
            child.start()
        }
    }
}
