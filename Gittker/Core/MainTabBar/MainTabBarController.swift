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
    var userdata: UserSchema
    
    init(with user: UserSchema) {
        self.userdata = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coordinator1 = HomeCoordinator(with: nil, user: userdata)
        let navigationController1 = UINavigationController(rootViewController: coordinator1.currentController!)
        coordinator1.navigationController = navigationController1
        coordinator1.tabController = self
        coordinator1.currentController?.tabBarItem = UITabBarItem(title: "Home",
                                                                  image: UIImage(systemName: "message.fill"),
                                                                  tag: 1)

        let coordinator2 = SearchCoordinator(with: nil)
        let navigationController2 = UINavigationController(rootViewController: coordinator2.currentController!)
        coordinator2.navigationController = navigationController2
        coordinator2.tabController = self
        coordinator2.currentController?.tabBarItem = UITabBarItem(title: "Search",
                                                                  image: UIImage(systemName: "magnifyingglass"),
                                                                  tag: 2)
        
        let coordinator3 = PeopleCoordinator(with: nil)
        let navigationController3 = UINavigationController(rootViewController: coordinator3.currentController!)
        coordinator3.navigationController = navigationController3
        coordinator3.tabController = self
        coordinator3.currentController?.tabBarItem = UITabBarItem(title: "People",
                                                                  image: UIImage(systemName: "person.fill"),
                                                                  tag: 3)

        
        let coordinator4 = CommunitiesCoordinator(with: nil)
        let navigationController4 = UINavigationController(rootViewController: coordinator4.currentController!)
        coordinator4.navigationController = navigationController4
        coordinator4.tabController = self
        coordinator4.currentController?.tabBarItem = UITabBarItem(title: "Communities",
                                                                  image: UIImage(systemName: "person.3.fill"),
                                                                  tag: 4)


        viewControllers = [
            navigationController1,
            navigationController2,
            navigationController3,
            navigationController4,
        ]
    }
}
