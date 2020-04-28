//
//  RoomsCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsCoordinator: NSObject, Coordinator {
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: RoomsViewController?
    
    var userdata: UserSchema
    
    init(with navigationController: ASNavigationController?, user: UserSchema) {
        self.navigationController = navigationController
        self.userdata = user
        super.init()
        
        currentController = RoomsViewController(coordinator: self)
        childCoordinators.append(self)
    }
    
    func start() {
//        navigationController?.pushViewController(currentController!, animated: true)
        navigationController?.delegate = self
    }
    
    func showChat(roomSchema: RoomSchema) {
        let coord = RoomChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema,
                                        isJoined: true,
                                        flow: .full)
        childCoordinators.append(coord)
        coord.start()
    }
    
    func previewChat(roomSchema: RoomSchema) -> RoomChatViewController {
        let coord = RoomChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema,
                                        isJoined: true,
                                        flow: .preview)
        return coord.currentController!
    }
    
    func showSuggestedRoom(with rooms: Array<RoomSchema>?, currentlyJoinedRooms: [RoomSchema]) {
        let coord = SuggestedRoomsCoordinator(
            with: navigationController,
            rooms: rooms,
            currentlyJoinedRooms: currentlyJoinedRooms,
            flow: SuggestedRoomsCoordinator.SuggestedFlow.chat
        )
        childCoordinators.append(coord)
        coord.start()
        
        self.currentController?.view = coord.currentController?.view
    }
    
    func removeSuggestedCoordinator() {
        self.childCoordinators.removeLast()
    }
    
    func showCreateRoom() {
        let coord = CreateRoomCoordinator(with: navigationController)
        childCoordinators.append(coord)
        coord.start()
        
        coord.onDismissed = {
            self.removeDependency(coord)
        }
    }
}

extension RoomsCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        // Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        // We’re still here – it means we’re popping the view controller, so we can check whether it’s a view controller
        if let roomChatController = fromViewController as? RoomChatViewController {
            // We're popping a view controller; end its coordinator
            self.removeDependency(roomChatController.coordinator)
        }
    }
}
