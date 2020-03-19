//
//  RoomsLogic.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

// https://developer.gitter.im/docs/rooms-resource
struct RoomSchema: Codable {
    let id: String                       // Room ID.
    let name: String                     // Room name.
    let topic: String?                   // Room topic. (default: GitHub repo description)
    let avatarUrl: String?
    let uri: String?                     // Room URI on Gitter.
    let oneToOne: Bool?                  // Indicates if the room is a one-to-one chat.
    let users: [UserSchema]?             // List of users in the room.
    let userCount: Int?                  // Count of users in the room.
    let unreadItems: Int?                // Number of unread messages for the current user.
    let mentions: Int?                   // Number of unread mentions for the current user.
    let lastAccessTime: String?          // Last time the current user accessed the room in ISO format.
    let favourite: Int?                  // Indicates if the room is on of your favourites.
    let lurk: Bool?                      // Indicates if the current user has disabled notifications.
    let url: String?                     // Path to the room on gitter.
    let githubType: Self.RoomTypeSchema? // Type of the room.
    let tags: [String]?                  // Tags that define the room.
    let v: Int?                          // Room version.
    let security: String?
    let noindex: Bool?
    let roomMember: Bool?
    let groupId: String?
    let `public`: Bool?
    
    enum RoomTypeSchema: String, Codable {
        case Org = "ORG" // A room that represents a GitHub Organisation.
        case Repo = "REPO" // A room that represents a GitHub Repository.
        case OneToOne = "ONETOONE" // A one-to-one chat.
        case OrgChannel = "ORG_CHANNEL" // A one-to-one chat.
        case RepoChannel = "REPO_CHANNEL" // A Gitter channel nested under a GitHub Repository.
        case UserChannel = "USER_CHANNEL" // A Gitter channel nested under a GitHub User.
        
        enum Key: String, CodingKey {
            case Org = "ORG"
            case Repo = "REPO"
            case OneToOne = "ONETOONE"
            case OrgChannel = "ORG_CHANNEL"
            case RepoChannel = "REPO_CHANNEL"
            case UserChannel = "USER_CHANNEL"
        }
    }
}
