//
//  UserChatViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 4/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit


class UserChatViewModel {
    
    private let roomSchema: UserRoomIntermediate
    private var messagesListInfo: [RoomRecreateSchema]?
    private lazy var cachedMessageLoader = CachedRoomMessagesLoader(cacheKey: self.roomSchema.id)
    
    init(roomSchema: UserRoomIntermediate) {
        self.roomSchema = roomSchema
    }
    
    func loadFirstMessages(completion: @escaping (([NiceterMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            CachedRoomMessagesLoader(cacheKey: self.roomSchema.id)
                .fetchData { (roomRecrList) in
                    self.messagesListInfo = roomRecrList
                    completion(roomRecrList.toGittkerMessages(isLoading: false))
            }
        }
    }
    
    func loadOlderMessages(messageId: String, completion: @escaping (([NiceterMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            GitterApi.shared.loadOlderMessage(messageId: messageId, roomId: self.roomSchema.id) { (roomRecrList) in
                guard let messages = roomRecrList?.toGittkerMessages(isLoading: false) else { return }
                completion(messages)
            }
        }
    }
    
    func sendMessage(text: String,
                     completion: @escaping (Result<RoomRecreateSchema, GitterApiErrors.MessageFailedError>) -> Void) {
        GitterApi.shared.sendGitterMessage(roomId: self.roomSchema.id, text: text) { (res) in
            guard let result = res else { return }
            completion(result)
        }
    }
    
    func markMessagesAsRead(userId: String, messagesId: [String], completion: (() -> Void)? = nil) {
        GitterApi.shared.markMessagesAsRead(messagesId: messagesId, roomId: self.roomSchema.id, userId: userId) { (success) in }
    }
    
    func joinToChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void)) {
        GitterApi.shared.joinUserChat(username: self.roomSchema.name ?? "") { (res) in
            completion(res)
        }
    }
    
    func reportMessage(messageId: String, completion: @escaping (ReportMessageSchema) -> Void) {
        GitterApi.shared.reportMessage(roomId: roomSchema.id, messageId: messageId) { (reportMessageSchema) in
            completion(reportMessageSchema)
        }
    }
    
    func deleteMessage(messageId: String, completion: @escaping (SuccessSchema) -> Void) {
        GitterApi.shared.deleteMessage(roomId: roomSchema.id, messageId: messageId) { (emptyTuple) in
            print(emptyTuple)
        }
    }
    
    func addNewMessageToCache(message: NiceterMessage) {
        DispatchQueue.global(qos: .default).async {
            self.cachedMessageLoader.addNewMessage(message: message)
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
