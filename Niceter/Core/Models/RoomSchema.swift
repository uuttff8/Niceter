//
//  RoomsLogic.swift
//  Niceter
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

// https://developer.gitter.im/docs/rooms-resource
@frozen
public struct RoomSchema: Codable, Equatable {
    var id: String                       // Room ID.
    let name: String?                    // Room name.
    var topic: String?                   // Room topic. (default: GitHub repo description)
    let avatarUrl: String?
    let uri: String?                     // Room URI on Gitter.
    let oneToOne: Bool?                  // Indicates if the room is a one-to-one chat.
    let users: [UserSchema]?             // List of users in the room.
    let userCount: Int?                  // Count of users in the room.
    var unreadItems: Int?                // Number of unread messages for the current user.
    let mentions: Int?                   // Number of unread mentions for the current user.
    var lastAccessTime: String?          // Last time the current user accessed the room in ISO format.
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
    
    @frozen
    public enum RoomTypeSchema: String, Codable {
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
        self.uri = user.displayName
        self.mentions = nil
        self.public = nil
        self.groupId = nil
        self.githubType = nil
        self.v = nil
        self.roomMember = nil
        self.tags = nil
        self.url = user.url
        self.lurk = nil
        self.favourite = nil
        self.lastAccessTime = nil
        self.unreadItems = nil
        self.users = nil
        self.userCount = nil
        self.security = nil
        self.noindex = nil
    }
    
    
    func getLastAccessDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = dateFormatter.date(from: lastAccessTime ?? "")
        return date
    }
    
    func getUsernameFromUrl() -> String { // used in one-to-one
        let username = self.url ?? ""
        return username.replacingOccurrences(of: "/", with: "")
    }
    
    func toIntermediate(isUser: Bool) -> UserRoomIntermediate {
        if isUser {
            return UserRoomIntermediate(id: self.id,
                                        name: self.name,
                                        avatarUrl: self.avatarUrl,
                                        uri: self.url?.replacingOccurrences(of: "/", with: ""))
        }
        return UserRoomIntermediate(id: self.id,
                                    name: self.name,
                                    avatarUrl: self.avatarUrl,
                                    uri: self.uri)
    }
}

// MARK: - Sorting Array
extension Array where Element == RoomSchema {
    func sortByUnreadAndFavourite() -> [RoomSchema] {
        var rooms = self.sorted { (a, b) -> Bool in
            if let a = a.unreadItems, let b = b.unreadItems {
                if a > 0 || b > 0 {
                    return a > b
                }
            }
            
            return false
        }
        
        rooms.forEach { (room) in
            if room.favourite != nil {
                rooms.move(room, to: 0)
            }
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
