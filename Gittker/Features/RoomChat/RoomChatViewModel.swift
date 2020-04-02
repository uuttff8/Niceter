//
//  ChatViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class RoomChatViewModel {
    
    private let roomSchema: RoomSchema
    private var messagesListInfo: [RoomRecreateSchema]?
    
    init(roomSchema: RoomSchema) {
        self.roomSchema = roomSchema
    }
    
    func loadFirstMessages(completion: @escaping (([GittkerMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            CachedRoomMessagesLoader(cacheKey: self.roomSchema.id)
                .fetchData { (roomRecrList) in
                    self.messagesListInfo = roomRecrList
                    completion(roomRecrList.toGittkerMessages(isLoading: false))
            }
        }
    }
    
    func loadOlderMessages(messageId: String, completion: @escaping (([GittkerMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            GitterApi.shared.loadOlderMessage(messageId: messageId, roomId: self.roomSchema.id) { (roomRecrList) in
                guard let messages = roomRecrList?.toGittkerMessages(isLoading: false) else { return }
                completion(messages)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping ((Result<RoomRecreateSchema, MessageFailedError>) -> Void)) {
        GitterApi.shared.sendGitterMessage(roomId: self.roomSchema.id, text: text) { (res) in
            guard let result = res else { return }
            completion(result)
        }
    }
    
    func markMessagesAsRead(userId: String, messagesId: [String], completion: (() -> Void)? = nil) {
        GitterApi.shared.markMessagesAsRead(messagesId: messagesId, roomId: self.roomSchema.id, userId: userId) { (success) in }
    }
    
    func joinToChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void)) {
        GitterApi.shared.joinRoom(userId: userId, roomId: roomId) { (success) in
            completion(success)
        }
    }
    
    // To implement it correct, we should better use caching to loading part of messages to cache
    func findFirstUnreadMessage() -> IndexPath? {
        guard let messages = messagesListInfo else { return nil }
        
        if let firstIndex = messages.firstIndex(where: { (roomRecrSchema) -> Bool in
            guard let unread = roomRecrSchema.unread else { return false }
            return unread == true
        }) {
            if firstIndex == 0 { return nil}
            return IndexPath(row: 0, section: firstIndex)
        }
        
        return nil
    }
}
