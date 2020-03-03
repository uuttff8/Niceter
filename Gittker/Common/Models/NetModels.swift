//
//  NetModels.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct ExchangeToken: Codable {
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

struct User: Codable {
    let id, username, displayName, url: String
    let avatarURL: String
    let avatarURLSmall, avatarURLMedium: String
    let providers: [String]
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id, username, displayName, url
        case avatarURL = "avatarUrl"
        case avatarURLSmall = "avatarUrlSmall"
        case avatarURLMedium = "avatarUrlMedium"
        case providers, v
    }
}


//struct User: Codable {
//    let id: String
//    let username: String
//    let displayName: String
//    let url: String
//    let avatarUrl: String
//    let avatarUrlSmall: String
//    let avatarUrlMedium: String
//    let providers: [String]
//    let v: Int
//    let gv: String
//}
