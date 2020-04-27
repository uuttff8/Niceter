//
//  PeopleCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class PeopleCoordinator: NSObject, Coordinator {
    
    weak var navigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
    weak var tabController: MainTabBarController?
    var currentController: PeopleViewController?

    init(with navigationController: ASNavigationController?) {
        self.navigationController = navigationController
        super.init()
        
        currentController = PeopleViewController(coordinator: self)
        childCoordinators.append(self)
    }
    
    func start() {
        navigationController?.delegate = self
    }
    
    func showChat(roomSchema: RoomSchema) {
        let coord = UserChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema.toIntermediate(isUser: true),
                                        isJoined: true,
                                        flow: .full)
        childCoordinators.append(coord)
        coord.start()
    }
    
    func previewChat(roomSchema: RoomSchema) -> UserChatViewController {
        let coord = UserChatCoordinator(with: navigationController,
                                        roomSchema: roomSchema.toIntermediate(isUser: true),
                                        isJoined: true,
                                        flow: .preview)
        return coord.currentController!
    }
    
    func showSuggestedRoom(with rooms: [UserSchema]?, currentlyJoinedRooms: [RoomSchema]) {
        let coord = SuggestedRoomsCoordinator(
            with: navigationController,
            rooms: rooms?.convertToRoomSchema(),
            currentlyJoinedRooms: currentlyJoinedRooms,
            flow: SuggestedRoomsCoordinator.SuggestedFlow.user
        )
        childCoordinators.append(coord)
        coord.start()
        
        self.currentController?.view = coord.currentController?.view
    }
    
    func removeSuggestedCoordinator() {
        self.childCoordinators.removeLast()
    }
}

extension PeopleCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        if let userChatController = fromViewController as? UserChatViewController {
            self.removeDependency(userChatController.coordinator)
        }
    }
}
