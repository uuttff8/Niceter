//
//  CommunitiesCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class CommunitiesCoordinator: Coordinator {

    weak var tabController: MainTabBarController?
    var currentController: CommunitiesViewController?
    
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()

    init(with navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
        currentController = CommunitiesViewController.instantiate(from: AppStoryboards.Communities)
        currentController?.coordinator = self
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
}

