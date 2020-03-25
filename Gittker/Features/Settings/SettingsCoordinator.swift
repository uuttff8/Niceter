//
//  SettingsCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class SettingsCoordinator: Coordinator {

    weak var tabController: MainTabBarController?
    var currentController: SettingsViewController?
    
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()

    init(with navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
        currentController = SettingsViewController()
        currentController?.coordinator = self
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
}

