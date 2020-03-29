//
//  FayeEventRoomBinder.swift
//  Gittker
//
//  Created by uuttff8 on 3/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Cache

public final class FayeEventRoomBinder {
    private var client: GitterFayeClient
        
    private let userId: String
    
    init(with userId: String) {
        self.userId = userId
        client = GitterFayeClient(endpoints: [.userRooms(userId)])
    }
    
    func subscribe(
        onNew: ((RoomSchema) -> Void)? = nil,
        onRemove: ((_ id: String) -> Void)? = nil,
        onPatch: ((RoomSchema) -> Void)? = nil
    ) {
        client.messageReceivedHandler = { (messageDict: [AnyHashable : Any], _ channel: String) in
            guard let data = messageDict.jsonData else { return }
            guard let event = try? JSONDecoder().decode(RoomEventSchema.self, from: data) else { return }
            
            
            
            switch event.operation {
            case .create:
                onNew?(event.model)
            case .remove:
                onRemove?(event.model.id)
            case .patch:
                print(data.prettyPrintedJSONString)
                onPatch?(event.model)
            }
        }
    }
}
