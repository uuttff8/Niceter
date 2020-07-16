//
//  RoomRecreate.swift
//  Niceter
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import MessageKit
import MarkdownKit

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
    let threadMessageCount: Int?
}

extension RoomRecreateSchema {
    func toGittkerMessage(isLoading: Bool) -> NiceterMessage {
        let user = MockUser(senderId: fromUser?.id ?? "",
                            displayName: fromUser?.displayName ?? "",
                            username: fromUser?.username ?? "")
        
        let md = GitterMarkdown()
        let message = MockMessage(attributedText: md.parse(self.text ?? ""),
                                  user: user,
                                  messageId: self.id,
                                  date: Date.toGittkerDate(str: self.sent!),
                                  originalText: self.text ?? "",
                                  unread: unread ?? false,
                                  threadMessageCount: self.threadMessageCount)
//        let message = MockMessage(text: self.text ?? "",
//                                  user: user,
//                                  messageId: self.id,
//                                  date: Date.toGittkerDate(str: self.sent!),
//                                  unread: unread ?? false)
        return NiceterMessage(message: message, avatarUrl: self.fromUser?.avatarURLMedium, isLoading: isLoading)
    }
}


extension Array where Element == RoomRecreateSchema {
    func toNiceterMessages(isLoading: Bool) -> Array<NiceterMessage> {
        return self.map { (roomRecrObject) in
            roomRecrObject.toGittkerMessage(isLoading: isLoading)
        }
    }
}

extension Date {
    static func toGittkerDate(str: String?) -> Date {
        guard let str = str else { return Date() }
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone.current
        // Safety: if error here then backend returned not valid sent date in string
        return dateFormatter.date(from: str)!
    }
}
