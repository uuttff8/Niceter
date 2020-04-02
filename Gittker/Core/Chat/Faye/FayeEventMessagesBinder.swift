//
//  FayeEventMessagesBinder.swift
//  Gittker
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Cache
import MessageKit

public final class FayeEventMessagesBinder {
    private var client: GitterFayeClient
    
    let diskConfig: DiskConfig
    let memoryConfig: MemoryConfig
    let storage: Storage<Array<RoomRecreateSchema>>?

    public var roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        client = GitterFayeClient(endpoints: [.roomsChatMessages(self.roomId)])
        
        diskConfig  = DiskConfig(name: "FayeMessagesEvents")
        memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        
        
        storage = try? Storage<Array<RoomRecreateSchema>>(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: Array<RoomRecreateSchema>.self)
        )
    }
    
    // MARK: - Messages
    
    func loadMessages(loadedMessages: @escaping ((Array<GittkerMessage>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cached = try? self.storage?.object(forKey: self.roomId) {
                loadedMessages(cached.toGittkerMessages(isLoading: false))
            }

            self.client.snapshotReceivedHandler = { (snapshot, _) in
                if let snap = snapshot as? Array<Dictionary<String, Any>> {
                    let roomRecrData = try? JSONSerialization.data(withJSONObject: snap, options: .prettyPrinted)

                    guard let roomRecr = try? JSONDecoder().decode(Array<RoomRecreateSchema>.self, from: roomRecrData!) else { print("blya"); return }

                    try? self.storage?.setObject(roomRecr, forKey: self.roomId)
                    let mess = roomRecr.toGittkerMessages(isLoading: false)
                    
                    loadedMessages(mess)
                }
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
            
            guard let event = try? JSONDecoder().decode(MessagesEventSchema.self, from: data) else { return }
            
            
            switch event.operation {
            case .create:
                let message = event.model.toGittkerMessage(isLoading: false)
                onNew?(message)
            case .update:
                let message = event.model.toGittkerMessage(isLoading: false)
                onUpdate?(message)
            case .remove:
                let id = event.model.id
                onDeleted?(id)
            }
        }
    }
}
