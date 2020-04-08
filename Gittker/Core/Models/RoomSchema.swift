//
//  RoomsLogic.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

// https://developer.gitter.im/docs/rooms-resource
struct RoomSchema: Codable, Equatable {
    let id: String                       // Room ID.
    let name: String?                    // Room name.
    var topic: String?                   // Room topic. (default: GitHub repo description)
    let avatarUrl: String?
    let uri: String?                     // Room URI on Gitter.
    let oneToOne: Bool?                  // Indicates if the room is a one-to-one chat.
    let users: [UserSchema]?             // List of users in the room.
    let userCount: Int?                  // Count of users in the room.
    var unreadItems: Int?                // Number of unread messages for the current user.
    let mentions: Int?                   // Number of unread mentions for the current user.
    var lastAccessTime: Date?            // Last time the current user accessed the room in ISO format.
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
    }
    
    func toSuggestedRoomContent() -> SuggestedRoomTableNode.Content {
        SuggestedRoomTableNode.Content(title: self.name ?? "", avatarUrl: self.avatarUrl ?? "", roomId: self.id)
    }
    
    public init(from user: UserSchema) {
        self.id = user.id
        self.avatarUrl = user.avatarURL
        self.name = user.username
        self.topic = nil
        self.oneToOne = nil
        self.uri = nil
        self.mentions = nil
        self.public = nil
        self.groupId = nil
        self.githubType = nil
        self.v = nil
        self.roomMember = nil
        self.tags = nil
        self.url = nil
        self.lurk = nil
        self.favourite = nil
        self.lastAccessTime = nil
        self.unreadItems = nil
        self.users = nil
        self.userCount = nil
        self.security = nil
        self.noindex = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        topic = try container.decodeIfPresent(String.self, forKey: .topic)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        uri = try container.decodeIfPresent(String.self, forKey: .uri)
        oneToOne = try container.decodeIfPresent(Bool.self, forKey: .oneToOne)
        users = try container.decodeIfPresent([UserSchema].self, forKey: .users)
        userCount = try container.decodeIfPresent(Int.self, forKey: .userCount)
        unreadItems = try container.decodeIfPresent(Int.self, forKey: .unreadItems)
        mentions = try container.decodeIfPresent(Int.self, forKey: .mentions)
        favourite = try container.decodeIfPresent(Int.self, forKey: .favourite)
        lurk = try container.decodeIfPresent(Bool.self, forKey: .lurk)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        githubType = try container.decodeIfPresent(Self.RoomTypeSchema.self, forKey: .githubType)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        v = try container.decodeIfPresent(Int.self, forKey: .v)
        security = try container.decodeIfPresent(String.self, forKey: .security)
        noindex = try container.decodeIfPresent(Bool.self, forKey: .noindex)
        roomMember = try container.decodeIfPresent(Bool.self, forKey: .roomMember)
        groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        `public` = try container.decodeIfPresent(Bool.self, forKey: .public)
        
        // really custom
        let dateString = try container.decodeIfPresent(String.self, forKey: .lastAccessTime)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = dateFormatter.date(from: dateString ?? "") {
            lastAccessTime = date
        } else {
            lastAccessTime = nil
//            throw DecodingError.dataCorruptedError(forKey: .lastAccessTime, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    }
}

// MARK: - Sorting Array
extension Array where Element == RoomSchema {
    func sortByUnreadAndLastAccess() -> [RoomSchema] {
        let rooms = self.sorted { (a, b) -> Bool in
            if let a = a.unreadItems, let b = b.unreadItems {
                if a > 0 || b > 0 {
                    return a > b
                }
            }
            
            if let a = a.lastAccessTime, let b = b.lastAccessTime {
                return a > b
            }
            
            return false
        }
        
        return rooms
    }
    
    func filterByChats() -> [RoomSchema] {
        let rooms = self.filter { (room) -> Bool in
            room.oneToOne == false
        }
        
        return rooms
    }
    
    func filterByPeople() -> [RoomSchema] {
        let rooms = self.filter { (room) -> Bool in
            room.oneToOne == true
        }
        
        return rooms
    }
}
