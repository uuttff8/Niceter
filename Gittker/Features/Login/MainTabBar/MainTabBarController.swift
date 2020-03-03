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
        
        let navigationController3 = UINavigationController()
        let coordinator3 = PeopleCoordinator(with: navigationController3)
        coordinator3.tabController = self
        coordinator3.currentController?.tabBarItem = UITabBarItem(title: "PEOPLE",
                                                                  image: nil,
                                                                  tag: 22)

        
        let navigationController4 = UINavigationController()
        let coordinator4 = CommunitiesCoordinator(with: navigationController4)
        coordinator4.tabController = self
        coordinator4.currentController?.tabBarItem = UITabBarItem(title: "COMMUNITIES",
                                                                  image: nil,
                                                                  tag: 22)



        viewControllers = [
            coordinator1.currentController!,
            coordinator2.currentController!,
            coordinator3.currentController!,
            coordinator4.currentController!
        ]

        tabBar.barTintColor = UIColor.white
        tabBar.isTranslucent = false

    }
}
