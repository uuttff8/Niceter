//
//  HomeCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeCoordinator: Coordinator {

    weak var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: HomeViewController?

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        currentController = HomeViewController.instantiate(from: AppStoryboards.Home)
        currentController?.coordinator = self
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
}
