//
//  LoginWebViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import WebKit

class LoginWebViewController: UIViewController, Storyboarded {

    open var authProvider: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        let url = navigationAction.request.url!
//
//        if (url.absoluteString.hasPrefix(appSettings!.oauthScope())) {
//            decisionHandler(.cancel)
//
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
//        } else {
//            decisionHandler(.allow)
//        }
    }
}
