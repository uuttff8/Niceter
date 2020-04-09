//
//  CommunitiesViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SettingsViewController: ASViewController<ASTableNode> {
    
    var coordinator: SettingsCoordinator
    
    lazy var viewModel: SettingsViewModel = SettingsViewModel(dataSource: self.tableDelegates)
    
    private let tableDelegates = SettingsTableDelegates()
    private var tableNode: ASTableNode {
        return node
    }

    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        super.init(node: ASTableNode(style: .insetGrouped))
        self.tableNode.dataSource = self.tableDelegates
        self.tableNode.delegate = self.tableDelegates
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        self.tableDelegates.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableNode.reloadData()
            }
        }
        
        self.tableDelegates.logoutAction = {
            self.logout()
        }
        
        self.viewModel.fetchDataSourceLocalData()
        self.viewModel.fetchDataSourceUser()
    }
    
    private func logout() {
        LoginData.shared.logout()
        
        // Safety: we use only one window
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        let root = ASNavigationController()
        window.rootViewController = root
        root.setNavigationBarHidden(true, animated: false)
        let child = LoginAuthCoordinator(navigationController: root)
        
        self.coordinator.childCoordinators.append(child)
        child.start()
        
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        
        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.3
        
        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
            { completed in
                
        })
    }
    
}

