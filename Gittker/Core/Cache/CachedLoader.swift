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
        memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10) // 10 min
        
        
        storage = try? Storage<T>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: T.self) // Storage<User>
        )
    }
    
    func fetchData(then handler: @escaping Handler) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cached = try? self.storage?.object(forKey: self.cacheKey) {
                handler(cached)
            }
            
        }
    }
}

class CachedRoomMessagesLoader: CachedLoader<[RoomRecreateSchema]> {
    private let roomId: String
    
    override init(cacheKey roomId: String) {
        self.roomId = roomId
        super.init(cacheKey: roomId)
    }
    
    
    override func fetchData(then handler: @escaping Handler) {
        super.fetchData(then: handler)
        
        GitterApi.shared.listMessagesUnread(roomId: roomId) { (roomRecrList) in
            guard let messages = roomRecrList else { return }
            try? self.storage?.setObject(messages, forKey: self.cacheKey)
            handler(messages)
        }
    }
}
