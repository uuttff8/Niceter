//
//  AppCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        if LoginData.shared.isLoggedIn() {
            let userdata = ShareData().userdata
            guard let user = userdata else { print("\(#file) \(#line) User is not initialized"); return }
            
            let tabBar = MainTabBarCoordinator(navigationController: navigationController, with: user)
            navigationController?.setNavigationBarHidden(true, animated: true)
            tabBar.start()
        } else {
            let child = LoginAuthCoordinator(navigationController: navigationController!)
            childCoordinators.append(child)
            child.start()
        }
    }
}
