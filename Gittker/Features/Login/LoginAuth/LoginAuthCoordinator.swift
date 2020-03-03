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
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = LoginAuthViewController.instantiate(from: AppStoryboards.LoginAuth)
        vc.coordinator = self
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showLoginWebView(host: String) {
        let vc = LoginWebViewController(nibName: nil, bundle: nil)
        vc.authProvider = host
        navigationController?.present(vc, animated: true, completion: nil)
    }
}
