//
//  FayeEndpoints.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

enum GitterFayeEndpoints {
    case userRooms(_ userId: String)                            // /api/v1/user/:userId/rooms
    case userUnreadItems(_ userId: String,_ roomId: String)     // /api/v1/user/:userId/rooms/:roomId/unreadItems
    case user(_ userId: String)                                 // /api/v1/user/:userId
    
    case rooms(_ roomId: String)                                // /api/v1/rooms/:roomId Room user presence.
    case roomsChatMessages(_ roomId: String)                    // /api/v1/rooms/:roomId/chatMessages
    case roomsUsers(_ roomId: String)                           // /api/v1/rooms/:roomId/users
    case roomsEvents(_ roomId: String)                          // /api/v1/rooms/:roomId/events
    case roomsReadBy(_ roomId: String, _ messageId: String)     // /api/v1/rooms/:roomId/chatMessages/:messageId/readBy
    
    func encode() -> String {
        switch self {
        case let .userRooms(userId):
            return "/api/v1/user/\(userId)/rooms"
        case let .userUnreadItems(userId, roomId):
            return "/api/v1/user/\(userId)/rooms/\(roomId)/unreadItems"
        case let .user(userId):
            return "/api/v1/user/\(userId)"
        case let .rooms(roomId):
            return "/api/v1/rooms/\(roomId)"
        case let .roomsChatMessages(roomId):
            return "/api/v1/rooms/\(roomId)/chatMessages"
        case let .roomsUsers(roomId):
            return "/api/v1/rooms/\(roomId)/users"
        case let .roomsEvents(roomId):
            return "/api/v1/rooms/\(roomId)/events"
        case let .roomsReadBy(roomId, messageId):
            return "/api/v1/rooms/\(roomId)/chatMessages/\(messageId)/readBy"
        }
    }
}
