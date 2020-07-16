//
//  ShowRepliesCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 7/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ShowRepliesCoordinator: Coordinator {
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    var currentController: ShowRepliesViewController?
    
    init(with navigationController: ASNavigationController?, roomRecreates: [RoomRecreateSchema], roomId: String) {
        self.navigationController = navigationController
        
        currentController = ShowRepliesViewController(coordinator: self, roomRecreates: roomRecreates, roomId: roomId)
    }
    
    func start() {
        navigationController?.pushViewController(currentController!, animated: true)
    }    
}

