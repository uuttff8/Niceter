//
//  RoomRecreate.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

struct UrlSchema: Codable {
    let url: String
}

#warning("Create mentions and issues schema")
//struct MentionSchema: Codable {
//
//}

struct RoomRecreateSchema: Codable {
    let id: String
    let v: Int
    let fromUser: UserSchema
//    let issues: [String]
    let urls: [UrlSchema]
    let text: String
//    let mentions: [String]
    let meta: [String]
    let sent: String
    let readBy: Int
    let unread: Bool
    let html: String
    
    func toMockMessage() -> MockMessage {
        let user = MockUser(senderId: fromUser.id, displayName: fromUser.displayName!)
        let message = MockMessage(text: self.text, user: user, messageId: self.id, date: Date())
        return message
    }
    
    func getAvatar() -> Avatar? {
        return try? Avatar(image: UIImage(withContentsOfUrl: URL(string: fromUser.avatarURL!)!), initials: "?")
    }

}


extension Array where Element == RoomRecreateSchema {
    func toGittkerMessages() -> Array<GittkerMessage> {
        var gittMess = Array<GittkerMessage>()
        
        self.forEach({ (roomRecrObject) in
            let message = roomRecrObject.toMockMessage()
            let avatar = roomRecrObject.getAvatar()!
            
            gittMess.append(GittkerMessage(message: message, avatar: avatar))
        })
        
        return gittMess
    }

}
