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
    
    let keychain = KeychainSwift()
    
    var userdata: UserSchema? {
        get {
            let data = keychain.getData(ShareDataConstants.userdata)
            return try? JSONDecoder().decode(UserSchema.self, from: data!)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            keychain.set(data!, forKey: ShareDataConstants.userdata)
            
        }
    }
}

