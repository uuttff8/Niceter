//
//  ChatViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class RoomChatViewModel {
    
    private let roomId: String
    private var messagesListInfo: [RoomRecreateSchema]?
    
    init(roomId: String) {
        self.roomId = roomId
    }
    
    func loadFirstMessages(completion: @escaping (([GittkerMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            CachedRoomMessagesLoader(cacheKey: self.roomId)
                .fetchData { (roomRecrList) in
                    self.messagesListInfo = roomRecrList
                    completion(roomRecrList.toGittkerMessages())
            }
        }
    }
    
    func loadOlderMessages(messageId: String, completion: @escaping (([GittkerMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            GitterApi.shared.loadOlderMessage(messageId: messageId, roomId: self.roomId) { (roomRecrList) in
                guard let messages = roomRecrList?.toGittkerMessages() else { return }
                completion(messages)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping ((Result<RoomRecreateSchema, MessageFailedError>) -> Void)) {
        GitterApi.shared.sendGitterMessage(roomId: self.roomId, text: text) { (res) in
            guard let result = res else { return }
            completion(result)
        }
    }
    
    func markMessagesAsRead(userId: String, completion: (() -> Void)? = nil) {
        GitterApi.shared.markMessagesAsRead(roomId: self.roomId, userId: userId) { (success) in }
    }
    
    func joinToChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void)) {
        GitterApi.shared.joinRoom(userId: userId, roomId: roomId) { (success) in
            completion(success)
        }
    }
    
    // To implement, we should better use caching to loading part of messages to cache
    func findFirstUnreadMessage() -> IndexPath? {
        guard let messages = messagesListInfo else { return nil }
        
        if let index = messages.firstIndex(where: { (roomRecrSchema) -> Bool in
            guard let unread = roomRecrSchema.unread else { return false }
            return unread == true
        }) {
            return IndexPath(row: index, section: 0)
        }
        
        return nil
    }
}
