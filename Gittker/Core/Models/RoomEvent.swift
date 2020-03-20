//
//  RoomEvent.swift
//  Gittker
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

struct RoomEventSchema: Codable {
    
    enum Event: String, Codable {
        case create = "create"
        case update = "update"
        case remove = "remove"
        
        enum Key: String, CodingKey {
            case update = "create"
            case create = "update"
            case remove = "remove"
        }
    }
    
    let operation: Self.Event
    let model: ModelEventSchema
    
    func createGittkerMessage() -> GittkerMessage? {
        switch operation {
        case .create:
            return model.toGittkerMessage()
        default: return nil
        }
    }
}

struct ModelEventSchema: Codable {
    let id: String
    
    let v: Int?
    let fromUser: UserSchema?
    let editedAt: String?
    let issues: [String]?
    let urls: [String]?
    let text: String?
    let mentions: [String]?
    let meta: [String]?
    let sent: String?
    let readBy: Int?
    let unread: Bool?
    let html: String?
    
    func toGittkerMessage() -> GittkerMessage {
        GittkerMessage(message: getMockMessage(), avatar: getAvatar())
    }
    
    private func getMockMessage() -> MockMessage {
        let user = MockUser(senderId: fromUser!.id, displayName: fromUser!.displayName)
        let message = MockMessage(text: self.text!, user: user, messageId: self.id, date: Date())
        return message
    }
    
    private func getAvatar() -> Avatar? {
        guard let avatarUrlString = fromUser?.avatarURLSmall else {
            return nil
        }
        
        return try? Avatar(image: UIImage(withContentsOfUrl: URL(string: avatarUrlString)!), initials: "?")
    }
}


// create
//{
//  "model": {
//    "id": "5e6fcba927fc6910a424bf22",
//    "v": 1,
//    "fromUser": {
//      "displayName": "Anton Kuzmin",
//      "id": "5ac21dd2d73408ce4f940b10",
//      "avatarUrlSmall": "https://avatars1.githubusercontent.com/u/40335671?v=4&s=60",
//      "avatarUrl": "https://avatars-01.gitter.im/gh/uv/4/uuttff8",
//      "username": "uuttff8",
//      "avatarUrlMedium": "https://avatars1.githubusercontent.com/u/40335671?v=4&s=128",
//      "v": 109,
//      "gv": "4",
//      "url": "/uuttff8"
//    },
//    "issues": [],
//    "urls": [],
//    "text": "Getted message 3",
//    "mentions": [],
//    "meta": [],
//    "sent": "2020-03-16T18:55:37.254Z",
//    "readBy": 0,
//    "unread": false,
//    "html": "Getted message 3"
//  },
//  "operation": "create"
//}

// update
//{
//  "operation": "update",
//  "model": {
//    "id": "5e6fcba927fc6910a424bf22",
//    "v": 2,
//    "fromUser": {
//      "displayName": "Anton Kuzmin",
//      "id": "5ac21dd2d73408ce4f940b10",
//      "avatarUrlSmall": "https://avatars1.githubusercontent.com/u/40335671?v=4&s=60",
//      "avatarUrl": "https://avatars-01.gitter.im/gh/uv/4/uuttff8",
//      "username": "uuttff8",
//      "avatarUrlMedium": "https://avatars1.githubusercontent.com/u/40335671?v=4&s=128",
//      "v": 109,
//      "gv": "4",
//      "url": "/uuttff8"
//    },
//    "editedAt": "2020-03-16T18:56:42.500Z",
//    "issues": [],
//    "urls": [],
//    "text": "Getted message 4",
//    "mentions": [],
//    "meta": [],
//    "sent": "2020-03-16T18:55:37.254Z",
//    "readBy": 0,
//    "unread": false,
//    "html": "Getted message 4"
//  }
//}


// remove
//{
//  "model": {
//    "id": "5e6fcbf89442097b254f20b8"
//  },
//  "operation": "remove"
//}
