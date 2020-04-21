//
//  LoginData.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import KeychainSwift

struct ShareDataConstants {
    static let accessToken = "access_token"
    static let userId = "userId"
    static let userdata = "userdata"
    static let currentlyJoinedChats = "currentlyJoinedChats"
    static let currentlyJoinedUsers = "currentlyJoinedUsers"
}

extension UserDefaults {
    static var appShared: UserDefaults {
        UserDefaults(suiteName: "userDefaults.uuttff8.Gittker")!
    }
}

class LoginData {
    static let shared = LoginData()
    
    private let keychain = KeychainSwift()
    private let userDefaults = UserDefaults.appShared
    
    func logout() {
        // proof
        keychain.clear()
        keychain.clear()
        userDefaults.removeSuite(named: "userDefaults.uuttff8.Gittker")
        userDefaults.resetDefaults()
        URLCache.shared.removeAllCachedResponses()
    }
    
    func setLoggedIn(_ userId:String) {
        self.userId = userId
    }
    
    func getCurrentUser() -> UserSchema? {
        ShareData().userdata
    }
    
    // LEGACY
    func isLoggedIn() -> Bool {
        return accessToken != nil && userId != nil
    }
    
    var accessToken: String? {
        get { keychain.get(ShareDataConstants.accessToken) }
        set { keychain.set(newValue!, forKey: ShareDataConstants.accessToken) }
    }
    
    var userId: String? {
        get { userDefaults.string(forKey: ShareDataConstants.userId) }
        set { userDefaults.set(newValue, forKey: ShareDataConstants.userId) }
    }

    func clear() {
        keychain.clear()
        clearUserId()
    }
    
    private func clearUserId() {
        userDefaults.removeObject(forKey: "userId")
    }
}
