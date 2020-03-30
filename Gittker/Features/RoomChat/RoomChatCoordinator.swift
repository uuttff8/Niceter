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
    
    var currentController: RoomChatViewController?
    var roomId: String
    var isJoined: Bool
    
    init(with navigationController: ASNavigationController?, roomId: String, isJoined: Bool) {
        self.navigationController = navigationController
        self.isJoined = isJoined
        self.roomId = roomId
        
        currentController = RoomChatViewController(coordinator: self, roomId: roomId, isJoined: isJoined)
    }
    
    func start() {
        guard let vc = currentController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}
