//
//  RoomRecreate.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

@frozen
public struct UrlSchema: Codable {
    let url: String
}

@frozen
public struct RoomRecreateSchema: Codable {
    let id: String
    let text: String?
    let html: String?
    let sent: String?
    let fromUser: UserSchema?
    let unread: Bool?
    let readBy: Int?
    let urls: [UrlSchema]?
//    let mentions: Int?
//    let issues: [String]?
    let meta: [String]?
    let v: Int?
}

extension RoomRecreateSchema {
    func toGittkerMessage(isLoading: Bool) -> GittkerMessage {
        let user = MockUser(senderId: fromUser?.id ?? "", displayName: fromUser?.displayName ?? "")
        let message = MockMessage(text: self.text ?? "",
                                  user: user,
                                  messageId: self.id,
                                  date: Date.toGittkerDate(str: self.sent!),
                                  unread: unread ?? false)
        return GittkerMessage(message: message, avatarUrl: self.fromUser?.avatarURLMedium, isLoading: isLoading)
    }
}


extension Array where Element == RoomRecreateSchema {
    func toGittkerMessages(isLoading: Bool) -> Array<GittkerMessage> {
        return self.map { (roomRecrObject) in
            roomRecrObject.toGittkerMessage(isLoading: isLoading)
        }
    }
}

private extension Date {
    static func toGittkerDate(str: String?) -> Date {
        guard let str = str else { return Date() }
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // Safety: if error here then backend returned not valid sent date in string
        return dateFormatter.date(from: str)!
    }
}
