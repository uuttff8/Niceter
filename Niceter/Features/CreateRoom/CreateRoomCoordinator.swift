//
//  CreateRoomCoordinator.swift
//  Niceter
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomCoordinator: Coordinator {
    weak var navigationController: ASNavigationController?
    var modalNavigationController: ASNavigationController?
    var childCoordinators = [Coordinator]()
    
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
    
    func showEnteringName(ghRepoEnabled: Bool, completion: @escaping (String) -> Void) {
        guard let modalNavController = modalNavigationController else { return }
        
        let vc = CreateRoomNameViewController(coordinator: self, ghRepoEnabled: ghRepoEnabled)
        modalNavController.pushViewController(vc, animated: true)
        vc.completionHandler = { (name) in
            completion(name)
        }
    }
    
    func showCommunityPick(adminGroups: [GroupSchema],
                           completion: @escaping (GroupSchema, _ ghRepoEnabled: Bool) -> Void) {
        guard let modalNavController = modalNavigationController else { return }
        
        let vc = CreateRoomCommunityViewController(coordinator: self, adminGroups: adminGroups)
        modalNavController.pushViewController(vc, animated: true)
        vc.completionHandler = { (group, ghRepoEnabled) in
            completion(group, ghRepoEnabled)
        }
    }
}
