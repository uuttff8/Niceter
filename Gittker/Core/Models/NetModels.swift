//
//  NetModels.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
public struct ExchangeTokenSchema: Codable {
    var clientId: String
    var clientSecret: String
    var redirectUri: String
    var grantType: String
    var code: String
    
    @frozen
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectUri = "redirect_uri"
        case grantType = "grant_type"
        case code
    }
}

@frozen
public struct UserSchema: Codable, Hashable, Equatable {
    let id: String
    let username: String?
    let displayName, url: String?
    let website: String?
    let avatarURL: String?
    let avatarURLSmall, avatarURLMedium: String?
    let company: String?
    let location: String?
    let email: String?
    let github: GitterUserInfo?
    let profile: String?
    let providers: [String]?
    let v: Int?

    @frozen enum CodingKeys: String, CodingKey {
        case id, username, displayName, url
        case avatarURL = "avatarUrl"
        case avatarURLSmall = "avatarUrlSmall"
        case avatarURLMedium = "avatarUrlMedium"
        case providers, v
        case company, location, email
        case github, profile, website
    }
    
    func toMockUser() -> MockUser {
        MockUser(senderId: self.id, displayName: self.displayName ?? "", username: self.username ?? "")
    }
    
    func getGitterImage() -> String? {
        if let username = self.username {
            return "https://avatars-05.gitter.im/gh/uv/4/\(username)?s=256"
        }
        
        return nil
    }
}

extension Array where Element == UserSchema {
    func convertToRoomSchema() -> [RoomSchema] {
        let rooms = self.map { (user) -> RoomSchema in
            RoomSchema(from: user)
        }
        
        return rooms
    }
}

// ["access_token": "xxxx", "token_type": Bearer]
@frozen public struct AccessTokenSchema: Codable {
    let accessToken: String
    let tokenType: String
    
    @frozen enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

@frozen public struct GitterUserInfo: Codable, Hashable, Equatable {
    let followers: Int?
    let public_repos: Int?
    let following: Int?
}


// UserSchema: twitter
//{
//    "id": "57338479c43b8c6019725b6d",
//    "username": "MadLittleMods_twitter",
//    "displayName": "MadLittleMods",
//    "has_gitter_login": true,
//    "gravatarImageUrl": "https://pbs.twimg.com/profile_images/2151224316/Mad_normal.png"
//}

// UserSchema: github
//{
//    "id": "553d437215522ed4b3df8c50",
//    "username": "MadLittleMods",
//    "displayName": "Eric Eastwood",
//    "has_gitter_login": true,
//    "company": "@gitlabhq",
//    "location": "MN",
//    "email": "contact@ericeastwood.com",
//    "website": "https://ericeastwood.com",
//    "profile": "https://github.com/MadLittleMods",
//    "github": {
//        "followers": 204,
//        "public_repos": 44,
//        "following": 15
//    },
//    "gv": "4"
//}

// UserSchema: gitlab
//{
//    "id": "5b159b6dd73408ce4f9bf356",
//    "username": "MadLittleMods_gitlab",
//    "displayName": "Eric Eastwood",
//    "has_gitter_login": true,
//    "gravatarImageUrl": "https://secure.gravatar.com/avatar/4d634a2b818e2265fa2924b5f4c2da71?s=80&d=identicon"
//}
