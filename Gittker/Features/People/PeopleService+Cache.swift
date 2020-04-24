//
//  PeopleService+Cache.swift
//  Gittker
//
//  Created by uuttff8 on 4/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

class CachedPeopleLoader: CachedLoader {
    typealias Handler = ([RoomSchema]) -> Void
    typealias CodeType = [RoomSchema]
    
    var diskConfig: DiskConfig
    var memoryConfig: MemoryConfig
    var storage: Storage<[RoomSchema]>?
    
    var cacheKey: String

    init(cacheKey: String) {
        self.cacheKey = cacheKey
        self.diskConfig = DiskConfig(name: self.cacheKey, expiry: .never)
        self.memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 100)
        
        self.storage = try? Storage<[RoomSchema]>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: [RoomSchema].self)
        )
    }

    func fetchData(then handler: @escaping Handler) {
        self.storage?.async.object(forKey: self.cacheKey, completion: { result in
            switch result {
              case .value(let rooms):
                handler(rooms)
              case .error(let error):
                GittkerLog.logCacheError(title: "Failed to fetch people loader cache", error: error)
            }
        })

        GitterApi.shared.getRooms { (roomsSchema) in
            self.storage?.async.setObject(roomsSchema, forKey: self.cacheKey, completion: { _ in })
            handler(roomsSchema)
        }
    }
    
    func fetchNewAndCache(then handler: @escaping Handler) {
        GitterApi.shared.getRooms { (roomsSchema) in
            self.storage?.async.setObject(roomsSchema, forKey: self.cacheKey, completion: { (_) in })
            handler(roomsSchema)
        }
    }
}
