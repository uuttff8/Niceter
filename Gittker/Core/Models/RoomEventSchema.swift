//
//  RoomEventSchema.swift
//  Gittker
//
//  Created by uuttff8 on 3/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct RoomEventSchema: Codable {
    @frozen enum Event: String, Codable {
        case create = "create"
//        case update = "update"
        case remove = "remove"
        case patch  = "patch"
    }
    
    let operation: Self.Event
    let model: RoomSchema
}

// CREATE
//{
//  "model" : {
//    "id" : "56f176fc85d51f252aba32d5",
//    "lurk" : false,
//    "public" : true,
//    "uri" : "ASDAlexander77\/cs2cpp",
//    "noindex" : false,
//    "roomMember" : true,
//    "url" : "\/ASDAlexander77\/cs2cpp",
//    "avatarUrl" : "https:\/\/avatars-02.gitter.im\/group\/iv\/4\/57542c9cc43b8c6019774dd2",
//    "topic" : "",
//    "unreadItems" : 0,
//    "security" : "PUBLIC",
//    "meta" : {
//
//    },
//    "oneToOne" : false,
//    "userCount" : 17,
//    "mentions" : 0,
//    "lastAccessTime" : "2020-03-28T17:03:02.441Z",
//    "githubType" : "REPO",
//    "groupId" : "57542c9cc43b8c6019774dd2",
//    "name" : "ASDAlexander77\/cs2cpp"
//  },
//  "operation" : "create"
//}

// DELETE
// when user deletes a room, backend returns 2 events:
//{
//  "model" : {
//    "id" : "570dce18187bb6f0eadf3111"
//  },
//  "operation" : "remove"
//}
//{
//  "model" : {
//    "id" : "570dce18187bb6f0eadf3111",
//    "unreadItems" : 0,
//    "mentions" : 0
//  },
//  "operation" : "patch"
//}

// PATCH
//{
//  "model" : {
//    "id" : "53d6ed74107e137846ba84d0",
//    "lastAccessTime" : "2020-03-28T16:58:45.468Z"
//  },
//  "operation" : "patch"
//}
//
//{
//  "model" : {
//    "id" : "56f176fc85d51f252aba32d5",
//    "unreadItems" : 0,
//    "mentions" : 0
//  },
//  "operation" : "patch"
//}
//
//{
//  "model" : {
//    "activity" : 0,
//    "id" : "56f176fc85d51f252aba32d5",
//    "favourite" : null,
//    "unreadItems" : 0,
//    "mentions" : 0,
//    "lastAccessTime" : null
//  },
//  "operation" : "patch"
//}
