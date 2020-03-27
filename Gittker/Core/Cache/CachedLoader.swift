//
//  CachedManager.swift
//  Gittker
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

class CachedLoader<T: Codable> {
    typealias Handler = (T) -> Void
    
    let diskConfig: DiskConfig
    let memoryConfig: MemoryConfig
    let storage: Storage<T>?
    
    let cacheKey: String
    
    init(cacheKey: String) {
        self.cacheKey = cacheKey
        diskConfig  = DiskConfig(name: cacheKey)
        memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        
        
        storage = try? Storage<T>(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: T.self) // Storage<User>
        )
    }
    
    func fetchData(then handler: @escaping Handler) {
        if let cached = try? storage?.object(forKey: cacheKey) {
            handler(cached)
        }
    }
}

class CachedSuggestedRoomLoader: CachedLoader<[RoomSchema]> {
    override func fetchData(then handler: @escaping Handler) {
        super.fetchData(then: handler)
        
        GitterApi.shared.getSuggestedRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
            handler(rooms)
        }
    }
}

class CachedRoomLoader: CachedLoader<[RoomSchema]> {
    override func fetchData(then handler: @escaping Handler) {
        super.fetchData(then: handler)
        
        GitterApi.shared.getRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
            handler(rooms)
        }
    }
}

class CachedRoomMessagesLoader: CachedLoader<[RoomRecreateSchema]> {
    override func fetchData(then handler: @escaping Handler) {
        super.fetchData(then: handler)
        
        GitterApi.shared.loadFirstMessages(for: cacheKey) { (roomRecrList) in
            guard let messages = roomRecrList else { return }
            try? self.storage?.setObject(messages, forKey: self.cacheKey)
            handler(messages)
        }
    }
}