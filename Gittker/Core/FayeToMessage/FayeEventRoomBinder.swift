//
//  FayeEventRoomBinder.swift
//  Gittker
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}

class FayeEventRoomBinder: NSObject {
    private var client: GitterFayeClient
    private let cache: CodableCache<Array<RoomRecreateSchema>>
    
    open var roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        client = GitterFayeClient(endpoints: [.roomsChatMessages(self.roomId)])
        self.cache = CodableCache<Array<RoomRecreateSchema>>(key: roomId)
        
        super.init()
    }
    
    // Load Messages
    func loadMessages(loadedMessages: @escaping ((Array<GittkerMessage>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cached = self.cache.get() {
                loadedMessages(cached.toGittkerMessages())
            }

            self.client.snapshotReceivedHandler = { (snapshot, _) in
                if let snap = snapshot as? Array<Dictionary<String, Any>> {
                    let roomRecrData = try? JSONSerialization.data(withJSONObject: snap, options: .prettyPrinted)

                    guard let roomRecr = try? JSONDecoder().decode(Array<RoomRecreateSchema>.self, from: roomRecrData!) else { print("blya"); return }

                    try? self.cache.set(value: roomRecr)

                    let mess = roomRecr.toGittkerMessages()
                    loadedMessages(mess)
                }
            }
        }
    }
    
    // New Message
    func onNewMessage(_ onNewMessage: @escaping ((GittkerMessage) -> Void)) {
        client.messageReceivedHandler = { (dict, _) in
            guard let data = dict.jsonData else { return }
            let event = try! JSONDecoder().decode(RoomEventSchema.self, from: data)
            
            switch event.operation {
            case .create:
                let message = event.model.toGittkerMessage()
                onNewMessage(message)
            default: return
            }
        }
    }
    
    func subscribe(
        onNew: ((GittkerMessage) -> Void)? = nil,
        onDeleted: ((_ id: String) -> Void)? = nil,
        onUpdate: ((GittkerMessage) -> Void)? = nil
    ) {
        
        client.messageReceivedHandler = { (dict, _) in
            guard let data = dict.jsonData else { return }
            let event = try! JSONDecoder().decode(RoomEventSchema.self, from: data)
            
            switch event.operation {
            case .create:
                let message = event.model.toGittkerMessage()
                onNew?(message)
            case .update:
                let message = event.model.toGittkerMessage()
                onUpdate?(message)
            case .remove:
                let id = event.model.id
                onDeleted?(id)
            }
        }
    }
}
