//
//  RoomChatCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomChatCoordinator: Coordinator {

    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    var roomId: String
    var isJoined: Bool
    
    init(with navigationController: ASNavigationController?, roomId: String, isJoined: Bool) {
        self.navigationController = navigationController
        self.isJoined = isJoined
        self.roomId = roomId
    }
    
    func start() {
        let vc = RoomChatViewController(coordinator: self, roomId: roomId, isJoined: isJoined)
        navigationController?.pushViewController(vc, animated: true)
    }
}
