//
//  CachedManager.swift
//  Niceter
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

class CachedRoomMessagesLoader: CachedLoader {
    typealias Handler = ([RoomRecreateSchema]) -> Void
    typealias CodeType = [RoomRecreateSchema]
    
    var diskConfig: DiskConfig
    var memoryConfig: MemoryConfig
    var storage: Storage<[RoomRecreateSchema]>?
    
    var cacheKey: String

    init(cacheKey: String) {
        self.cacheKey = cacheKey
        self.diskConfig = DiskConfig(name: cacheKey, expiry: .never)
        self.memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 100)
        
        self.storage = try? Storage<[RoomRecreateSchema]>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: [RoomRecreateSchema].self)
        )
    }

    
    func fetchData(then handler: @escaping Handler) {
        self.storage?.async.object(forKey: self.cacheKey, completion: { (res) in
            switch res {
            case .value(let roomRecrSchema):
                handler(roomRecrSchema)
            case .error(let error):
                NiceterLog.logCacheError(title: "Failed to fetch messages cache", error: error)
            }
        })
        
        GitterApi.shared.listMessagesUnread(roomId: self.cacheKey) { (roomRecrList) in
            guard let messages = roomRecrList else { return }
            self.storage?.async.setObject(messages, forKey: self.cacheKey, completion: { (_) in })
            handler(messages)
        }
    }
    
    func addNewMessage(message: NiceterMessage) {
        
        self.storage?.async.object(forKey: self.cacheKey, completion: { (res) in
            switch res {
            case .value(var rooms):
                rooms.append(message.toRoomRecreate()!)
                self.storage?.async.setObject(rooms, forKey: self.cacheKey, completion: { (_) in })
            case .error(let error):
                NiceterLog.logCacheError(title: "Failed to fetch adding messages cache", error: error)
            }
        })
    }
}
