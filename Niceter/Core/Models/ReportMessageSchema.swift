//
//  ReportMessageSchema.swift
//  Niceter
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
public struct ReportMessageSchema: Codable {
    let id: String
    let sent: String
    let weight: Int
    let reporterUserId: String
    let reporterUser: UserSchema
    let messageId: String
    let messageUserId: String
    let messageUser: UserSchema
    let messageText: String
    let message: RoomRecreateSchema
}
