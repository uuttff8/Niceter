//
//  NetModels.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct ExchangeTokenSchema: Codable {
    var clientId: String
    var clientSecret: String
    var redirectUri: String
    var grantType: String
    var code: String
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectUri = "redirect_uri"
        case grantType = "grant_type"
        case code
    }
}

struct UserSchema: Codable {
    let id, username: String
    let displayName, url: String
    let avatarURL: String?
    let avatarURLSmall, avatarURLMedium: String?
    let providers: [String]?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id, username, displayName, url
        case avatarURL = "avatarUrl"
        case avatarURLSmall = "avatarUrlSmall"
        case avatarURLMedium = "avatarUrlMedium"
        case providers, v
    }
    
    func toMockUser() -> MockUser {
        MockUser(senderId: self.id, displayName: self.displayName)
    }
}

// ["access_token": "xxxx", "token_type": Bearer]
struct AccessTokenSchema: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
