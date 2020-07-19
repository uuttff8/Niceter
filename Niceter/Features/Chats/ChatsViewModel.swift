//
//  ChatsViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 7/19/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

protocol ChatDescriptor {
    typealias SendMessageCompletion = ((Result<RoomRecreateSchema, GitterApiErrors.MessageFailedError>) -> Void)
    typealias VoidNiceterMessageCompletion = (([NiceterMessage]) -> Void)
    typealias VoidRoomRecreateCompletion = (RoomRecreateSchema) -> Void
    
    var roomSchema: UserRoomIntermediate { get set }
    
    func loadFirstMessages(completion: @escaping VoidNiceterMessageCompletion)
    func loadOlderMessages(messageId: String, completion: @escaping VoidNiceterMessageCompletion)
    func loadMessageThread(messageId: String, completion: @escaping ([RoomRecreateSchema]) -> Void)
    func markMessagesAsRead(userId: String, messagesId: [String], completion: (() -> Void)?)
    
    func sendMessage(text: String, completion: @escaping SendMessageCompletion)
    func reportMessage(messageId: String, completion: @escaping (ReportMessageSchema) -> Void)
    func deleteMessage(messageId: String, completion: @escaping () -> Void)
    func editMessage(text: String, messageId: String, completion: @escaping VoidRoomRecreateCompletion)
    
    func addNewMessageToCache(message: NiceterMessage)
}

protocol RoomChatDescritor {
    func joinToRoomChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void))
    func prefetchRoomUsers()
}

protocol UserChatDescritor {
    func joinToUserChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void))
}

class ChatsViewModel: ChatDescriptor {    
    typealias SendMessageCompletion = ((Result<RoomRecreateSchema, GitterApiErrors.MessageFailedError>) -> Void)
    
    public var roomSchema: UserRoomIntermediate
    private var messagesListInfo: [RoomRecreateSchema]?
    private lazy var cachedMessageLoader = CachedRoomMessagesLoader(cacheKey: self.roomSchema.id)
    
    // for room chat
    var roomUsersIn = [UserSchema]()
    
    init(roomSchema: UserRoomIntermediate) {
        self.roomSchema = roomSchema
    }
    
    func loadFirstMessages(completion: @escaping (([NiceterMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            GitterApi.shared.listMessagesUnread(roomId: self.roomSchema.id) { (roomRecrList) in
                guard let messages = roomRecrList else { return }
                completion(messages.toNiceterMessages(isLoading: false))
            }
        }
    }
    
    func loadOlderMessages(messageId: String, completion: @escaping (([NiceterMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            GitterApi.shared.loadOlderMessage(messageId: messageId, roomId: self.roomSchema.id) { (roomRecrList) in
                guard let messages = roomRecrList?.toNiceterMessages(isLoading: false) else { return }
                completion(messages)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping SendMessageCompletion) {
        GitterApi.shared.sendGitterMessage(roomId: self.roomSchema.id, text: text) { (res) in
            guard let result = res else { return }
            completion(result)
        }
    }
    
    func markMessagesAsRead(userId: String, messagesId: [String], completion: (() -> Void)?) {
        GitterApi.shared.markMessagesAsRead(messagesId: messagesId, roomId: self.roomSchema.id, userId: userId) { (success) in }
    }
    
    func reportMessage(messageId: String, completion: @escaping (ReportMessageSchema) -> Void) {
        GitterApi.shared.reportMessage(roomId: roomSchema.id, messageId: messageId) { (reportMessageSchema) in
            completion(reportMessageSchema)
        }
    }
    
    func deleteMessage(messageId: String, completion: @escaping () -> Void) {
        GitterApi.shared.deleteMessage(roomId: roomSchema.id, messageId: messageId) { (_) in
            completion()
        }
    }
    
    func addNewMessageToCache(message: NiceterMessage) {
        DispatchQueue.global(qos: .default).async {
            self.cachedMessageLoader.addNewMessage(message: message)
        }
    }
    
    func editMessage(text: String, messageId: String, completion: @escaping (RoomRecreateSchema) -> Void) {
        GitterApi.shared.updateMessage(text: text, roomId: roomSchema.id, messageId: messageId, completion: completion)
    }
    
    func loadMessageThread(messageId: String, completion: @escaping ([RoomRecreateSchema]) -> Void) {
        GitterApi.shared.loadMessageThread(roomId: self.roomSchema.id, messageId: messageId, completion: completion)
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

// MARK: - RoomChat related
extension ChatsViewModel {
    func prefetchRoomUsers() {
        CachedPrefetchRoomUsers(cacheKey: Config.CacheKeys.roomUsers(roomId: roomSchema.id), roomId: roomSchema.id)
            .fetchData { (usersSchema) in
                self.roomUsersIn = usersSchema
        }
    }
    
    func joinToRoomChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void)) {
        GitterApi.shared.joinRoom(userId: userId, roomId: roomId) { (success) in
            completion(success)
        }
    }
}

extension ChatsViewModel {
    func joinToUserChat(userId: String, roomId: String, completion: @escaping ((RoomSchema) -> Void)) {
        GitterApi.shared.joinUserChat(username: self.roomSchema.name ?? "") { (res) in
            completion(res)
        }
    }
}
