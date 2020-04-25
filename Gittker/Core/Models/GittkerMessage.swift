//
//  GittkerMessage.swift
//  Gittker
//
//  Created by uuttff8 on 3/19/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

struct GittkerMessage {
    var message: MockMessage
    let avatarUrl: String?
    let isLoading: Bool
}

extension GittkerMessage: Equatable {
    static func == (lhs: GittkerMessage, rhs: GittkerMessage) -> Bool {
        return
            lhs.message == rhs.message &&
            lhs.avatarUrl == rhs.avatarUrl &&
            lhs.isLoading == rhs.isLoading
        
    }
}

extension GittkerMessage {
    func toRoomRecreate() -> RoomRecreateSchema? {
//        let user = MockUser(senderId: fromUser?.id ?? "", displayName: fromUser?.displayName ?? "", username: fromUser?.username ?? "")
//        let message = MockMessage(text: self.text ?? "",
//                                  user: user,
//                                  messageId: self.id,
//                                  date: Date.toGittkerDate(str: self.sent!),
//                                  unread: unread ?? false)
//        return GittkerMessage(message: message, avatarUrl: self.fromUser?.avatarURLMedium, isLoading: isLoading)
        if case let MessageKind.text(text) = message.kind {
            
            let date = Date.strFromDate(message.sentDate)
            let user = UserSchema(id: message.user.senderId, username: message.user.username, displayName: message.user.displayName, url: nil, website: nil, avatarURL: nil, avatarURLSmall: nil, avatarURLMedium: avatarUrl, company: nil, location: nil, email: nil, github: nil, profile: nil, providers: nil, v: nil)
            
            
            return RoomRecreateSchema(id: message.messageId, text: text, html: nil, sent: date, fromUser: user, unread: false, readBy: nil, urls: nil, meta: nil, v: nil)
            
        } else {
            return nil
        }
    }
}

private extension Date {
    static func strFromDate(_ date: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // Safety: if error here then backend returned not valid sent date in string
        return dateFormatter.string(from: date)
    }
}
