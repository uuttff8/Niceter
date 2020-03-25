//
//  CachedManager.swift
//  Gittker
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class CachedLoader<T: Codable> {
    typealias Handler = (T) -> Void
    
    fileprivate let cache: CodableCache<T>
    
    init(cacheKey: AnyHashable) {
        cache = CodableCache<T>(key: cacheKey)
    }
    
    func fetchData(then handler: @escaping Handler) {
        if let cached = cache.get() {
            handler(cached)
        }

    }
}

class CachedSuggestedRoomLoader: CachedLoader<[RoomSchema]> {
    override func fetchData(then handler: @escaping ([RoomSchema]) -> Void) {
        super.fetchData(then: handler)
        
        GitterApi.shared.getSuggestedRooms { [weak self] (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self?.cache.set(value: rooms)
            handler(rooms)
        }
    }
}

class CachedRoomLoader: CachedLoader<[RoomSchema]> {
    override func fetchData(then handler: @escaping ([RoomSchema]) -> Void) {
        super.fetchData(then: handler)
        GitterApi.shared.getRooms { [weak self] (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self?.cache.set(value: rooms)
            handler(rooms)
        }
    }
}

class CachedRoomMessagesLoader: CachedLoader<[RoomRecreateSchema]> {
    
    private let roomId: String
    
    override init(cacheKey: AnyHashable) {
        self.roomId = cacheKey as? String ?? ""
        super.init(cacheKey: cacheKey)
    }
    
    override func fetchData(then handler: @escaping ([RoomRecreateSchema]) -> Void) {
        super.fetchData(then: handler)
        
        GitterApi.shared.loadFirstMessages(for: roomId) { [weak self] (roomRecrList) in
            guard let messages = roomRecrList else { return }
            try? self?.cache.set(value: messages)
            handler(messages)
        }
    }
}
