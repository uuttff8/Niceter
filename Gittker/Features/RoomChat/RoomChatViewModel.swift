//
//  ChatViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class RoomChatViewModel {
    func loadFirstMessages(roomId: String, completion: @escaping ((Array<GittkerMessage>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            CachedRoomMessagesLoader(cacheKey: roomId)
                .loadMessages { (roomRecrList) in
                    let messages = roomRecrList.toGittkerMessages()
                    completion(messages)
            }
        }
    }
    
    func loadOlderMessages(messageId: String, roomId: String, completion: @escaping ((Array<GittkerMessage>) -> Void)) {
        GitterApi.shared.loadOlderMessage(messageId: messageId, roomId: roomId) { (roomRecrList) in
            guard let messages = roomRecrList?.toGittkerMessages() else { return }
            completion(messages)
        }
    }
}
