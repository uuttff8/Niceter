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

    private let host = "https://gitter.im"
    private let appSettings = AppSettingsSecret()
//    private let OATHKEY = "bab3c21b76d47686e5b28792b9d17864d72c4878"
//    private let OAUTHSCOPE = "gittker://"
    
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
            URLQueryItem(name: "client_id", value: appSettings.clientID),
            URLQueryItem(name: "redirect_uri", value: appSettings.scope),
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

        if (url.absoluteString.hasPrefix(appSettings.scope)) {
            decisionHandler(.cancel)
            
            if let code = getCodeFromCallbackUrl(url) {

                exchangeTokens(code, completionHandler: { (accessToken) -> Void in

                    self.getUserId(accessToken, completionHandler: { (userId) -> Void in

                        // LoginData().setLoggedIn(userId, withToken: accessToken)
                        // NotificationCenter.default.post(name: Notification.Name(rawValue: TroupeAuthenticationReady), object: self)
                        self.showInitialViewController()

                    })

                })
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func getCodeFromCallbackUrl(_ url: URL) -> String? {
        print(url)
        return URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.filter({ (queryItem) -> Bool in
            return queryItem.name == "code"
        }).first?.value
    }
    
    private func exchangeTokens(_ code: String, completionHandler: @escaping (_ accessToken: String) -> Void) {
        let token = ExchangeToken(clientId: appSettings.clientID,
                                  clientSecret: appSettings.clientIDSecret,
                                  redirectUri: appSettings.scope,
                                  grantType: "authorization_code",
                                  code: code)
        
        GitterApi.init(accessToken: nil).exchangeToken(dataToken: token) { (token) in
            completionHandler(token)
        }
    }

    private func getUserId(_ accessToken: String, completionHandler: @escaping (_ userId: String) -> Void) {
        let api = GitterApi(accessToken: accessToken)
        api.getUserId { (user) in
            guard let user = user else { print("BLYAAAA");return }
            print(user.id)
            completionHandler(user.id)
        }
    }

    private func showInitialViewController() {
        self.dismiss(animated: true, completion: {
            let tabBar = MainTabBarCoordinator(navigationController: nil)
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = tabBar.currentController
            tabBar.start()
        })
    }
}
