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
    
    func loadMessages(loadedMessages: @escaping ((Array<GittkerMessage>) -> Void)) {
        if let cached = cache.get() {
            loadedMessages(cached.toGittkerMessages())
        }
        
        client.snapshotReceivedHandler = { (snapshot, _) in
            if let snap = snapshot as? Array<Dictionary<String, Any>> {
                let roomRecrData = try? JSONSerialization.data(withJSONObject: snap, options: .prettyPrinted)
                
                guard let roomRecr = try? JSONDecoder().decode(Array<RoomRecreateSchema>.self, from: roomRecrData!) else { print("blya"); return }
                
                try? self.cache.set(value: roomRecr)
                
                let mess = roomRecr.toGittkerMessages()
                loadedMessages(mess)
            }
        }
        
        return
    }
}

extension FayeEventRoomBinder {
    func onNewMessage(onNewMessage: @escaping ((GittkerMessage) -> Void)) {
        client.messageReceivedHandler = { (dict, _) in
            guard let data = dict.jsonData else { return }
            let event = try! JSONDecoder().decode(RoomEventSchema.self, from: data)
            
            if let message = event.createGittkerMessage() {
                onNewMessage(message)
            }
        }
                
    }
}
