//
//  MainTabBarController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class MainTabBarController: ASTabBarController {
    
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
        coordinator?.childCoordinators.append(homeCoordinator)
        let homeNavigationController = ASNavigationController(rootViewController: homeCoordinator.currentController!)
        homeCoordinator.navigationController = homeNavigationController
        homeCoordinator.tabController = self
        homeCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Rooms",
                                                                  image: UIImage(systemName: "message"),
                                                                  tag: 0)

        
        let peopleCoordinator = PeopleCoordinator(with: nil)
        coordinator?.childCoordinators.append(peopleCoordinator)
        let peopleNavigationController = ASNavigationController(rootViewController: peopleCoordinator.currentController!)
        peopleCoordinator.navigationController = peopleNavigationController
        peopleCoordinator.tabController = self
        peopleCoordinator.currentController?.tabBarItem = UITabBarItem(title: "People",
                                                                  image: UIImage(systemName: "person"),
                                                                  tag: 1)

        
        let commCoordinator = SettingsCoordinator(with: nil)
        coordinator?.childCoordinators.append(commCoordinator)
        let commNavigationController = ASNavigationController(rootViewController: commCoordinator.currentController!)
        commCoordinator.navigationController = commNavigationController
        commCoordinator.tabController = self
        commCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Settings",
                                                                  image: UIImage(systemName: "gear"),
                                                                  tag: 2)
        

        viewControllers = [
            peopleNavigationController,
            homeNavigationController,
            commNavigationController,
        ]
        
        selectedIndex = 1
    }
}
