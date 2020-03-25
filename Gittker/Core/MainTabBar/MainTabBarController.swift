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
        
        let homeCoordinator = RoomsCoordinator(with: nil, user: userdata)
        let homeNavigationController = UINavigationController(rootViewController: homeCoordinator.currentController!)
        homeCoordinator.navigationController = homeNavigationController
        homeCoordinator.tabController = self
        homeCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Rooms",
                                                                  image: UIImage(systemName: "message"),
                                                                  tag: 0)

        
        let peopleCoordinator = PeopleCoordinator(with: nil)
        let peopleNavigationController = UINavigationController(rootViewController: peopleCoordinator.currentController!)
        peopleCoordinator.navigationController = peopleNavigationController
        peopleCoordinator.tabController = self
        peopleCoordinator.currentController?.tabBarItem = UITabBarItem(title: "People",
                                                                  image: UIImage(systemName: "person"),
                                                                  tag: 1)

        
        let commCoordinator = SettingsCoordinator(with: nil)
        let commNavigationController = UINavigationController(rootViewController: commCoordinator.currentController!)
        commCoordinator.navigationController = commNavigationController
        commCoordinator.tabController = self
        commCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Communities",
                                                                  image: UIImage(systemName: "person.3"),
                                                                  tag: 2)
        

        viewControllers = [
            peopleNavigationController,
            homeNavigationController,
            commNavigationController,
        ]
        
        selectedIndex = 1
    }
}
