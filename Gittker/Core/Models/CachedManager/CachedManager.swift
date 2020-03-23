//
//  CachedManager.swift
//  Gittker
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class CachedRoomLoader {
    typealias Handler = ([RoomSchema]) -> Void

    private let cache: CodableCache<[RoomSchema]>
    
    init(cacheKey: AnyHashable) {
        cache = CodableCache<[RoomSchema]>(key: cacheKey)
    }
    
    func loadRooms(then handler: @escaping Handler) {
        if let cached = cache.get() {
            handler(cached)
        }

        GitterApi.shared.getRooms { [weak self] (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self?.cache.set(value: rooms)
            handler(rooms)
        }
    }
}

class CachedRoomMessagesLoader {
    typealias Handler = ([RoomRecreateSchema]) -> Void

    private let cache: CodableCache<[RoomRecreateSchema]>
    private let roomId: String
    
    init(cacheKey: AnyHashable) {
        self.roomId = cacheKey as? String ?? ""
        cache = CodableCache<[RoomRecreateSchema]>(key: cacheKey)
    }
    
    func loadMessages(then handler: @escaping Handler) {
        if let cached = cache.get() {
            handler(cached)
        }

        GitterApi.shared.loadFirstMessages(for: roomId) { [weak self] (roomRecrList) in
            guard let messages = roomRecrList else { return }
            try? self?.cache.set(value: messages)
            handler(messages)
        }
    }
}
