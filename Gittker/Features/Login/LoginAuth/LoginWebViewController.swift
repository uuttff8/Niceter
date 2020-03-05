//
//  LoginWebViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import WebKit

class LoginWebViewController: UIViewController {
    typealias JsonObject = [String : Any]
    
    var activityView: UIActivityIndicatorView?
    
    open var authProvider: String?
    private var webView: WKWebView?
    
    var viewModel: LoginAuthViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel = LoginAuthViewModel(provider: authProvider!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        showActivityIndicator()
        ClearCookies {
            let webView = WKWebView()
            
            webView.isHidden = true
            webView.scrollView.bounces = false
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(webView)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide][webView]|", options: [], metrics: nil, views: ["topLayoutGuide": self.topLayoutGuide, "webView": webView]))
            webView.navigationDelegate = self
            webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
            self.webView = webView
            
            webView.load(URLRequest(url: self.viewModel?.getAuthorisationUrl() ?? URL(string: "")!))
        }
        
    }
    
    func makeUI() {
        view.backgroundColor = UIColor.systemBackground
    }
    
    
    // MARK: - Private methods
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            if (!webView!.isLoading) {
                hideActivityIndicator()
                webView!.isHidden = false
            }
        }
    }
    
}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url!
        
        if (url.absoluteString.hasPrefix(viewModel?.appSettings.scope ?? "")) {
            decisionHandler(.cancel)
            
            viewModel?.processAuthorisation(url: url, completion: { [weak self] (user) in
                self?.showInitialViewController(with: user)
            })
            
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func showInitialViewController(with user: User) {
        self.dismiss(animated: true, completion: {
            let tabBar = MainTabBarCoordinator(navigationController: nil, with: user)
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = tabBar.currentController
            tabBar.start()
        })
    }
}
