//
//  AppSettingsSecret.swift
//  Niceter
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class AppSettingsSecret {
    
    private let bundleSecretPath = Bundle.main.path(forResource: "GitterSecrets-Dev", ofType: "plist")!
    private var bundleSecret: NSDictionary? {
        return NSDictionary(contentsOfFile: bundleSecretPath)
    }
    private var defaults: UserDefaults {
        let def = UserDefaults.standard
        
        def.register(defaults: bundleSecret as! [String : Any])
        
        return def
    }
    
    init () {
        guard bundleSecret != nil else { print("You should provide Gitter Secrets"); return }
    }
    
    
    // You must not change Gitter secrets dev keys!
    var clientID: String {
        defaults.string(forKey: "OAuthClientId")!
    }
    
    var scope: String {
        defaults.string(forKey: "OAuthCallback")!
    }
    
    var clientIDSecret: String {
        defaults.string(forKey: "OAuthClientSecret")!
    }
}
