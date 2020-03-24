//
//  LoginAuthCoordinator.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class LoginAuthCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController?
    var currentController: LoginAuthViewController
        
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
        currentController = LoginAuthViewController.instantiate(from: AppStoryboards.LoginAuth)
    }
    
    func start() {
        currentController.coordinator = self
        navigationController?.pushViewController(currentController, animated: true)
    }
    
    func showLoginWebView(host: String) {
        let vc = LoginWebViewController(nibName: nil, bundle: nil)
        vc.authProvider = host
        navigationController?.present(vc, animated: true, completion: nil)
    }
}
