//
//  CreateRoomCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomCoordinator: Coordinator {
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: CreateRoomViewController?
    
    
    init(with navigationController: ASNavigationController?) {
        self.navigationController = navigationController
        
        currentController = CreateRoomViewController(coordinator: self)
        childCoordinators.append(self)
    }
    
    func start() {
        guard let currentController = currentController else { return }
        self.navigationController?.present(currentController, animated: true, completion: nil)
    }
}
