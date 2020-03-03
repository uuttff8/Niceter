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

    var activityView: UIActivityIndicatorView?

    
    open var authProvider: String?
    
    private var webView: WKWebView?

    private let host = "https://gitter.im"
    private let OATHKEY = "bab3c21b76d47686e5b28792b9d17864d72c4878"
    private let OAUTHSCOPE = "gittker://"
    
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

            webView.load(URLRequest(url: self.getAuthorisationUrl()))
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
    
    private func getAuthorisationUrl() -> URL {
        var components = URLComponents(string: "\(host)/login/oauth/authorize")!
        var queryItems = [
            URLQueryItem(name: "client_id", value: OATHKEY),
            URLQueryItem(name: "redirect_uri", value: OAUTHSCOPE),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "action", value: "login"),
            URLQueryItem(name: "source", value: "ios_login-login")
        ]
        if let authProvider = self.authProvider {
            queryItems.append(URLQueryItem(name: "auth_provider", value: authProvider))
        }
        components.queryItems = queryItems

        return components.url!
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

        if (url.absoluteString.hasPrefix(OAUTHSCOPE)) {
            decisionHandler(.cancel)

//            if let code = getCodeFromCallbackUrl(url) {
//
//                exchangeTokens(code, completionHandler: { (accessToken) -> Void in
//
//                    self.getUserId(accessToken, completionHandler: { (userId) -> Void in
//
//                        LoginData().setLoggedIn(userId, withToken: accessToken)
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: TroupeAuthenticationReady), object: self)
//                        self.showInitialViewController()
//
//                    })
//
//                })
//
//            }
        } else {
            decisionHandler(.allow)
        }
    }
}
