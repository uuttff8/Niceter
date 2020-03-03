//
//  ViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class LoginAuthViewController: UIViewController, Storyboarded {

    weak var coordinator: LoginAuthCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - VC Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    @IBAction func gitLabButtonTapped(_ sender: RoundButton) {
        coordinator?.showLoginWebView(host: "gitlab")
    }
    
    @IBAction func gitHubButtonTapped(_ sender: RoundButton) {
        coordinator?.showLoginWebView(host: "github")
    }
    
    @IBAction func twitterButtonTapped(_ sender: RoundButton) {
        coordinator?.showLoginWebView(host: "twitter")
    }
}

