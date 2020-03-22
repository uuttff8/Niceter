//
//  RoomChatCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class RoomChatCoordinator: Coordinator {

    weak var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()
    
    var roomId: String
    
    init(with navigationController: UINavigationController?, roomId: String) {
        self.navigationController = navigationController
        self.roomId = roomId
    }
    
    func start() {
        let vc = RoomChatViewController.instantiate(from: AppStoryboards.Chat)
        vc.coordinator = self
        vc.roomId = roomId
        childCoordinators.append(self)
        navigationController?.pushViewController(vc, animated: true)
    }
}
