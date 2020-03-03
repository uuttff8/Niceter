//
//  MainTabBarController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    weak var coordinator: MainTabBarCoordinator?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController1 = UINavigationController()
        let coordinator1 = HomeCoordinator(with: navigationController1)
        coordinator1.tabController = self
        coordinator1.currentController?.tabBarItem = UITabBarItem(title: "HOME",
                                                                  image: nil,
                                                                  tag: 11)

        let navigationController2 = UINavigationController()
        let coordinator2 = SearchCoordinator(with: navigationController2)
        coordinator2.tabController = self
        coordinator2.currentController?.tabBarItem = UITabBarItem(title: "ABOUT",
                                                                  image: nil,
                                                                  tag: 22)


        viewControllers = [
            coordinator1.currentController!,
            coordinator2.currentController!
        ]

        tabBar.barTintColor = UIColor.white
        tabBar.isTranslucent = false

    }
}
