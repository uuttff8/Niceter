//
//  MainTabBarCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var childCoordinators = [Coordinator]()


    var currentController: MainTabBarController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
        self.currentController = MainTabBarController()
        self.childCoordinators.append(self)
        currentController?.coordinator = self

    }
    
    func start() {
        navigationController?.pushViewController(currentController ?? UIViewController(),
                                                 animated: true)

    }

    func fetchHome(with title: String, completion:  @escaping (_ result: Dictionary<String,Any>, _ error: NSError?) -> ()) {

        completion(["ss":"ss"], nil)

    }


    func handleAbout(with title: String, completion: @escaping (_ result: Dictionary<String,Any>, _ error: NSError?) -> ()) {

        completion(["ss":"ss"], nil)
    }

}
