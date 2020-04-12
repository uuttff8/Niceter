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
    
    var diskConfig: DiskConfig
    var memoryConfig: MemoryConfig
    var storage: Storage<[RoomRecreateSchema]>?

    public var roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        client = GitterFayeClient(endpoints: [.roomsChatMessages(self.roomId)])
        
        diskConfig  = DiskConfig(name: "FayeMessagesEvents")
        memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        
        
        storage = try? Storage<[RoomRecreateSchema]>(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: [RoomRecreateSchema].self)
        )
    }
    
    // MARK: - Messages
    
    func loadMessages(loadedMessages: @escaping (([GittkerMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.storage?.async.object(forKey: self.roomId) { res in
                switch res {
                case .value(let user):
                    loadedMessages(user.toGittkerMessages(isLoading: false))
                case .error(let error):
                    break
                }
            }

            self.client.snapshotReceivedHandler = { (snapshot, _) in
                if let snap = snapshot as? [Dictionary<String, Any>] {
                    let roomRecrData = try? JSONSerialization.data(withJSONObject: snap, options: .prettyPrinted)

                    guard let roomRecr = try? JSONDecoder().decode([RoomRecreateSchema].self, from: roomRecrData!) else { print("blya"); return }

                    self.storage?.async.setObject(roomRecr, forKey: self.roomId, completion: { (_) in })
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
    
    func cancel() {
        client.disconnect()
    }
}
