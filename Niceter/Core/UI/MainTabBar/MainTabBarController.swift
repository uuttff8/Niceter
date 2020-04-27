//
//  MainTabBarController.swift
//  Niceter
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

protocol TabBarReselectHandling {
    func handleReselect()
}

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
        self.delegate = self
        
        let homeCoordinator = RoomsCoordinator(with: nil, user: userdata)
        coordinator?.childCoordinators.append(homeCoordinator)
        let homeNavigationController = ASNavigationController(rootViewController: homeCoordinator.currentController!)
        homeCoordinator.navigationController = homeNavigationController
        homeCoordinator.start()
        homeCoordinator.tabController = self
        homeCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Rooms".localized(),
                                                                  image: UIImage(systemName: "message"),
                                                                  tag: 0)

        
        let peopleCoordinator = PeopleCoordinator(with: nil)
        coordinator?.childCoordinators.append(peopleCoordinator)
        let peopleNavigationController = ASNavigationController(rootViewController: peopleCoordinator.currentController!)
        peopleCoordinator.navigationController = peopleNavigationController
        peopleCoordinator.start()
        peopleCoordinator.tabController = self
        peopleCoordinator.currentController?.tabBarItem = UITabBarItem(title: "People".localized(),
                                                                  image: UIImage(systemName: "person"),
                                                                  tag: 1)

        
        let commCoordinator = SettingsCoordinator(with: nil)
        coordinator?.childCoordinators.append(commCoordinator)
        let commNavigationController = ASNavigationController(rootViewController: commCoordinator.currentController!)
        commCoordinator.navigationController = commNavigationController
        commCoordinator.tabController = self
        commCoordinator.currentController?.tabBarItem = UITabBarItem(title: "Settings".localized(),
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

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        let controller = viewController as? ASNavigationController
        let tabBarControllerVC = tabBarController.selectedViewController as? ASNavigationController
        if tabBarControllerVC?.viewControllers.first === controller?.viewControllers.first,
            let handler = tabBarControllerVC?.viewControllers.first as? TabBarReselectHandling {
            // NOTE: viewController in line above might be a UINavigationController,
            // in which case you need to access its contents
            handler.handleReselect()
        }

        return true
    }
}
