//
//  RoomEvent.swift
//  Gittker
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct RoomEvent: Codable {
    
    enum Event {
        case create
        case update
        case remove
    }
    
    let operation: String
    let model: ModelEventSchema
    
    func operationCase() -> Event? {
        switch operation {
        case "create": return Event.create
        case "update": return Event.update
        case "remove": return Event.remove
        default: print("unexpected operation"); return nil
        }
    }
}

struct ModelEventSchema: Codable {
    let id: String
    
    let v: Int?
    let fromUser: User?
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


protocol EnumDecodable: RawRepresentable, Decodable {
    static func defaultDecoderValue() throws -> Self
}

enum EnumDecodableError: Swift.Error {
    case noValue
}

extension EnumDecodable {
    static func defaultDecoderValue() throws -> Self {
        throw EnumDecodableError.noValue
    }
}

extension EnumDecodable where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        self = try Self(rawValue: value) ?? Self.defaultDecoderValue()
    }
}
