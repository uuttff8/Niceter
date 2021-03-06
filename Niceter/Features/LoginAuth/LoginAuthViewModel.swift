//
//  LoginAuthViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 3/4/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class LoginAuthViewModel {
    open var authProvider: String
    
    init(provider: String) {
        self.authProvider = provider
    }
    
    private let host = "https://gitter.im"
    let appSettings = AppSettingsSecret()
    
    func processAuthorisation(url: URL, completion: @escaping ((_ user: UserSchema) -> Void)) {
        if let code = getCodeFromCallbackUrl(url) {
            
            exchangeTokens(code, completionHandler: { (authAccessToken) -> Void in
                
                LoginData.shared.accessToken = authAccessToken
                
                self.getUser(completionHandler: { (gettedUser) -> Void in
                    ShareData().userdata = gettedUser
                    LoginData().setLoggedIn(gettedUser.id)
                    // NotificationCenter.default.post(name: Notification.Name(rawValue: TroupeAuthenticationReady), object: self)
                    completion(gettedUser)
                })
                
            })
        }
    }
    
    func getAuthorisationUrl() -> URL {
        var components = URLComponents(string: "\(host)/login/oauth/authorize")!
        
        var queryItems = [
            URLQueryItem(name: "client_id", value: appSettings.clientID),
            URLQueryItem(name: "redirect_uri", value: appSettings.scope),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "action", value: "login"),
            URLQueryItem(name: "source", value: "ios_login-login")
        ]
        queryItems.append(URLQueryItem(name: "auth_provider", value: authProvider))
        components.queryItems = queryItems

        return components.url!
    }
    
    func getCodeFromCallbackUrl(_ url: URL) -> String? {
        print(url)
        return URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.filter({ (queryItem) -> Bool in
            return queryItem.name == "code"
        }).first?.value
    }
    
    func exchangeTokens(_ code: String, completionHandler: @escaping (_ accessToken: String) -> Void) {
        let token = ExchangeTokenSchema(clientId: appSettings.clientID,
                                  clientSecret: appSettings.clientIDSecret,
                                  redirectUri: appSettings.scope,
                                  grantType: "authorization_code",
                                  code: code)
        
        GitterApi.shared.exchangeToken(dataToken: token) { (token) in
            completionHandler(token)
        }
    }

    func getUser(completionHandler: @escaping (_ userId: UserSchema) -> Void) {
        GitterApi().getWhoMe { (user) in
            guard let user = user else { return }
            print(user)
            completionHandler(user)
        }
    }
}
