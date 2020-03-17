//
//  FayeEventRoomBinder.swift
//  Gittker
//
//  Created by uuttff8 on 3/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import MessageKit

class FayeEventRoomBinder: NSObject {
    
    private var client: GitterFayeClient
    
    open var roomId: String
        
    init(roomId: String) {
        self.roomId = roomId
        client = GitterFayeClient(endpoints: [.roomsChatMessages(self.roomId)])
        
        super.init()
    }
    
    func onNewMessage(onNewMessage: @escaping ((MockMessage) -> Void)) {
        client.messageReceivedHandler = { (dict, _) in
            print(dict)
            guard let data = dict.jsonData else { return }
            let event = try! JSONDecoder().decode(RoomEvent.self, from: data)
            print(event)
            
            switch event.operationCase() {
            case .create:
                let user = MockUser(senderId: event.model.fromUser!.id, displayName: (event.model.fromUser?.displayName!)!)
                let message = MockMessage(text: event.model.text!, user: user, messageId: event.model.id, date: Date())
                
                onNewMessage(message)
            default: break
            }
        }
                
    }
    
    func loadMessages(loadedMessages: @escaping (([MockMessage]) -> Void)) {
        client.snapshotReceivedHandler = { (snapshot, _) in
            if let snap = snapshot as? Array<Dictionary<String, Any>> {
                let roomRecrData = try? JSONSerialization.data(withJSONObject: snap, options: .prettyPrinted)
                
                let roomRecr = try? JSONDecoder().decode([RoomRecreate].self, from: roomRecrData!)
                
                var messageArray = [MockMessage]()
                
                roomRecr?.forEach({ (roomRecrObject) in
                    
                    let user = MockUser(senderId: roomRecrObject.fromUser.id, displayName: (roomRecrObject.fromUser.displayName!))
                    let message = MockMessage(text: roomRecrObject.text, user: user, messageId: roomRecrObject.id, date: Date())
                    
                    messageArray.append(message)
                })
                
                loadedMessages(messageArray)
            }
        }
    }
    
}

extension Dictionary {
    var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
