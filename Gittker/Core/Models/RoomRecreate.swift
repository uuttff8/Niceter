//
//  RoomRecreate.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct RoomRecreate: Codable {
    let id: String
    let v: Int
    let fromUser: User
//    let issues: [AnyObject]
//    let urls: [Any]
    let text: String
//    let mentions: [Any]
//    let meta: [Any]
    let sent: String
    let readBy: Int
    let unread: Bool
    let html: String
}
