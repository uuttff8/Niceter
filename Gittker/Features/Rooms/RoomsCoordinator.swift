//
//  RoomsCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class RoomsCoordinator: Coordinator {

    weak var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: RoomsViewController?
    
    var userdata: UserSchema
    
    init(with navigationController: UINavigationController?, user: UserSchema) {
        self.navigationController = navigationController
        self.userdata = user
        
        currentController = RoomsViewController()
        currentController?.coordinator = self
        childCoordinators.append(self)
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }
    
    func showChat(roomId: String) {
        let coord = RoomChatCoordinator(with: navigationController, roomId: roomId)
        coord.start()
    }
    
    func showSuggestedRoom(with rooms: Array<RoomSchema>?) {
        self.currentController?.view = SuggestedRoomsCoordinator(with: navigationController, rooms: rooms).currentController?.view
    }
}
