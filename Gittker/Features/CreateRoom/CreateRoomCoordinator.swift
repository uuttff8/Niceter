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
    var modalNavigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: CreateRoomViewController?
    
    
    init(with navigationController: ASNavigationController?) {
        self.navigationController = navigationController
        
        self.currentController = CreateRoomViewController(coordinator: self)
        self.modalNavigationController = ASNavigationController(rootViewController: currentController!)
    }
    
    func start() {
        guard let modalNavController = modalNavigationController else { return }
        self.navigationController?.present(modalNavController, animated: true, completion: nil)
    }
    
    func showEnteringName() {
        guard let modalNavController = modalNavigationController else { return }
        
        let vc = CreateRoomNameViewController(coordinator: self)
        modalNavController.pushViewController(vc, animated: true)
    }
}
