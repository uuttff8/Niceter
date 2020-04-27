//
//  ViewController.swift
//  Niceter
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class LoginAuthViewController: PortaitViewController, Storyboarded {

    @IBOutlet weak var signInAcceptTextView: UITextView!
    @IBOutlet weak var gitlabButton: RoundButton! {
        didSet {
            self.gitlabButton.alpha = 0.0
        }
    }
    @IBOutlet weak var githubButton: RoundButton! {
        didSet {
            self.githubButton.alpha = 0.0
        }
    }
    @IBOutlet weak var twitterButton: RoundButton! {
        didSet {
            self.twitterButton.alpha = 0.0
        }

    }
    
    weak var coordinator: LoginAuthCoordinator?
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - VC Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) {
            self.githubButton.alpha = 1.0
            self.twitterButton.alpha = 1.0
            self.gitlabButton.alpha = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAcceptTextView()
    }
    
    private func setupAcceptTextView() {
        signInAcceptTextView.isUserInteractionEnabled = true
        signInAcceptTextView.isEditable = false
        signInAcceptTextView.attributedText = acceptAttributedString
        signInAcceptTextView.textAlignment = .center
    }
    
    private var acceptAttributedString: NSMutableAttributedString = {
        let plainAttributedString = NSMutableAttributedString(
            string: "By signing in you accept our ".localized(),
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )
        
        let attributedLinkStringTerms = NSMutableAttributedString(
            string: "Terms of use",
            attributes: [NSAttributedString.Key.link: URL(string: "https://about.gitlab.com/terms/")!,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )
        
        let attributeAnd = NSMutableAttributedString(
            string: " and ".localized(),
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )
        let attributedLinkStringPrivacy = NSMutableAttributedString(
            string: "Privacy Policy",
            attributes: [NSAttributedString.Key.link: URL(string: "https://about.gitlab.com/privacy/")!,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )
        
        let fullAttributedString = NSMutableAttributedString()
        fullAttributedString.append(plainAttributedString)
        fullAttributedString.append(attributedLinkStringTerms)
        fullAttributedString.append(attributeAnd)
        fullAttributedString.append(attributedLinkStringPrivacy)
        return fullAttributedString
    }()
    
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

