//
//  MockMessage.swift
//  Niceter
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

import Foundation
import CoreLocation
import MessageKit
import AVFoundation

private struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

}

private struct MockAudiotem: AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }

}

struct MockContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

struct MockUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var username: String
}

struct MockMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var unread: Bool
    var user: MockUser
    
    var kind: MessageKind
    var originalText: String
    var threadMessageCount: Int?
    var parentId: String?
    
    private init(kind: MessageKind,
                 user: MockUser,
                 messageId: String,
                 date: Date,
                 originalText: String,
                 unread: Bool,
                 threadMessageCount: Int?,
                 parentId: String?
    ) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.unread = unread
        self.originalText = originalText
        self.threadMessageCount = threadMessageCount
        self.parentId = parentId
    }
    
    func toUserSchema() -> UserSchema {
        UserSchema(id: self.messageId, username: self.user.username, displayName: self.user.displayName, url: nil, website: nil, avatarURL: nil, avatarURLSmall: nil, avatarURLMedium: nil, company: nil, location: nil, email: nil, github: nil, profile: nil, providers: nil, v: nil)
    }
    init(attributedText: NSAttributedString,
         user: MockUser,
         messageId: String,
         date: Date,
         originalText: String,
         unread: Bool,
         threadMessageCount: Int?,
         parentId: String?
    ) {
        self.init(kind: .attributedText(attributedText),
                  user: user,
                  messageId: messageId,
                  date: date,
                  originalText: originalText,
                  unread: unread,
                  threadMessageCount: threadMessageCount,
                  parentId: parentId)
    }
}

extension MessageKind: Equatable {
    public static func ==(lhs: MessageKind, rhs: MessageKind) -> Bool {
        switch (lhs, rhs) {
        case let (.text(l), .text(r)): return l == r
        case let (.attributedText(l), .attributedText(r)): return l == r
        default: return false
        }
    }
}


extension MockMessage: Equatable {
    static func == (lhs: MockMessage, rhs: MockMessage) -> Bool {
        return
            lhs.messageId == rhs.messageId &&
                lhs.sentDate == rhs.sentDate &&
                lhs.unread == rhs.unread &&
                lhs.user == rhs.user &&
                lhs.kind == rhs.kind
    }
}
