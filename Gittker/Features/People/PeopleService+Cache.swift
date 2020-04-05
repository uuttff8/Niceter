//
//  PeopleService+Cache.swift
//  Gittker
//
//  Created by uuttff8 on 4/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

//class CachedSuggestedRoomLoader: CachedLoader<[RoomSchema]> {
//    override func fetchData(then handler: @escaping Handler) {
//        super.fetchData(then: handler)
//        
//        GitterApi.shared.getSuggestedRooms { (roomSchemaList) in
//            guard let rooms = roomSchemaList else { return }
//            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
//            handler(rooms)
//        }
//    }
//}

class CachedPeopleLoader: CachedLoader<[RoomSchema]> {
    override func fetchData(then handler: @escaping Handler) {
        super.fetchData(then: handler)
        
        GitterApi.shared.getRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
            handler(rooms)
        }
    }
    
    func fetchNewAndCache(then handler: @escaping Handler) {
        // note: not calling super because we won't get cached value
        
        GitterApi.shared.getRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
            handler(rooms)
        }
    }
}
