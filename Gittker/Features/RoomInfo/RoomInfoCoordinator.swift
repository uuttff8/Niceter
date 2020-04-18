//
//  RoomInfoCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoCoordinator: Coordinator {
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var currentController: RoomInfoController?
    
    init(with navigation: ASNavigationController, roomSchema: RoomSchema) {
        self.navigationController = navigation
        
        self.currentController = RoomInfoController(coordinator: self, roomSchema: roomSchema)
    }
    
    func start() {
        guard let navigation = navigationController else { return }
        
        navigation.pushViewController(currentController!, animated: true)
    }
}
