//
//  KeychainSwiftWrapper.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import KeychainSwift

// work after auth
class ShareData {
    
    let userDefaults = UserDefaults.appShared
    
    var userdata: UserSchema? {
        get {
            guard let data = userDefaults.data(forKey: ShareDataConstants.userdata) else {
                return nil
            }
            return try? JSONDecoder().decode(UserSchema.self, from: data)
        } set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: ShareDataConstants.userdata)
        }
    }
}

