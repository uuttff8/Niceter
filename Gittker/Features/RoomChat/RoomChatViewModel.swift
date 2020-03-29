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
    
    init(roomId: String) {
        self.roomId = roomId
    }
    
    func loadFirstMessages(completion: @escaping ((Array<GittkerMessage>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            CachedRoomMessagesLoader(cacheKey: self.roomId)
                .fetchData { (roomRecrList) in
                    let messages = roomRecrList.toGittkerMessages()
                    completion(messages)
            }
        }
    }
    
    func loadOlderMessages(messageId: String, completion: @escaping ((Array<GittkerMessage>) -> Void)) {
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
        GitterApi.shared.markMessagesAsRead(roomId: self.roomId, userId: userId) { (success) in
            print(success.success)
        }
    }
}
