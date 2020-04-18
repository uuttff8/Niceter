//
//  GitterApiLinks.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
enum GitterApiLinks {
    private static let limitMessages = 100 // because limit of unread messages is 100
    
    static let baseUrl = "https://gitter.im/"
    static let baseUrlApi2 = "https://gitter.im/api/"
    static let baseUrlApi = "https://api.gitter.im/"
    
    // Auth
    case exchangeToken
    
    // User
    case user(username: String)
    case whoMe
    case searchUsers(query: String)
    case hideRoom(userId: String, roomId: String)
    case joinUserRoom
    
    // Rooms
    case suggestedRooms
    case rooms
    case readMessages(userId: String, roomId: String)
    case removeUser(userId: String, roomId: String) // This can be self-inflicted to leave the the room and remove room from your left menu.
    case joinRoom(userId: String, roomId: String)
    case searchRooms(_ query: String)
    case createRoom(_ groupId: String)
    case listUsers(roomId: String, skip: Int)
    
    // Messages
    case firstMessages(String)
    case olderMessages(messageId: String, roomId: String)
    case sendMessage(roomId: String)
    case listMessagesAround(roomId: String, messageId: String)
    case listMessagesUnread(roomId: String)
    case reportMessage(roomId: String, messageId: String)
    case deleteMessage(roomId: String, messageId: String)
    
    // Groups
    case adminGroups
    case userGroups
    case groupById(id: String)
    
    // Repos
    case repos
    
    func encode() -> String {
        switch self {
        case .exchangeToken: return "login/oauth/token"
        case .whoMe: return "v1/user/me"
        case .user(username: let username):
            return "v1/users/\(username)"
        case .searchUsers(query: let query):
            return "v1/user?q=\(query)&type=gitter"
        case .hideRoom(userId: let userId, roomId: let roomId):
            return "v1/user/\(userId)/rooms/\(roomId)"
        case .joinUserRoom:
            return "v1/rooms"
            
        case .rooms: return "v1/rooms"
        case .suggestedRooms: return "v1/user/me/suggestedRooms"
        case .readMessages(userId: let userId, roomId: let roomId):
            return "v1/user/\(userId)/rooms/\(roomId)/unreadItems"
        case .removeUser(userId: let userId, roomId: let roomId):
            return "v1/rooms/\(roomId)/users/\(userId)"
        case .joinRoom(userId: let userId, roomId: _):
            return "v1/user/\(userId)/rooms"
        case .searchRooms(let query):
            return "v1/rooms?q=\(query)"
        case .createRoom(let groupId):
            return "v1/groups/\(groupId)/rooms"
        case .listUsers(roomId: let roomId, skip: let skip):
            return "v1/rooms/\(roomId)/users?skip=\(skip)"
            
        case .firstMessages(let roomId): return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .olderMessages(messageId: let messageId, roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&beforeId=\(messageId)"
        case .sendMessage(roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages"
        case .listMessagesAround(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&aroundId=\(messageId)"
        case .listMessagesUnread(roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .reportMessage(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages/\(messageId)/report"
        case .deleteMessage(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages/\(messageId)"
            
        case .adminGroups:
            return "v1/groups?type=admin"
        case .userGroups:
            return "v1/user/me/groups"
        case .groupById(id: let id):
            return "v1/groups/\(id)"
            
        case .repos:
            return "v1/user/me/repos"
        }
    }
    
    var method: String {
        switch self {
        case .hideRoom(userId: _, roomId: _):
            return "DELETE"
        case .joinUserRoom:
            return "POST"
        case .removeUser(userId: _, roomId: _):
            return "DELETE"
        case .joinRoom(userId: _, roomId: _):
            return "POST"
        case .reportMessage(roomId: _, messageId: _):
            return "POST"
        default: return "GET"
        }
    }
}
