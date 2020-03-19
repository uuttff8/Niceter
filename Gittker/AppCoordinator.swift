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
        if LoginData.shared.isLoggedIn() {
            let userdata = ShareData().userdata
            guard let user = userdata else { print("\(#file) \(#line) User is not initialized"); return }
            
            let tabBar = MainTabBarCoordinator(navigationController: navigationController, with: user)
            window.rootViewController = tabBar.currentController
            navigationController?.setNavigationBarHidden(true, animated: true)
            tabBar.start()
        } else {
            let child = LoginAuthCoordinator(navigationController: navigationController!)
            window.rootViewController = child.currentController
            childCoordinators.append(child)
            child.start()
        }
    }
}
