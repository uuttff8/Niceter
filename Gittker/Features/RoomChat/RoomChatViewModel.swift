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
        FayeEventRoomBinder(roomId: roomId)
            .loadMessages { (gittMessages: Array<GittkerMessage>) in
                completion(gittMessages)
        }
    }
}
