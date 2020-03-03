//
//  PeopleCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class PeopleCoordinator: Coordinator {

    weak var tabController: MainTabBarController?
    var currentController: PeopleViewController?
    
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        currentController = PeopleViewController.instantiate(from: AppStoryboards.People)
        currentController?.coordinator = self
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
}
