//
//  RoomsService.swift
//  Gittker
//
//  Created by uuttff8 on 3/30/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

@frozen enum RoomsService {
    static func share(room: RoomSchema,
                      in viewController: UIViewController) {
        guard let uri = room.uri else { return }
        let text = "https://gitter.im/\(uri)?utm_source=share-link&utm_medium=link&utm_campaign=share-link"
        
        let activityViewController = UIActivityViewController(
            activityItems: [text], applicationActivities: nil)
        
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

class CachedSuggestedRoomLoader: CachedLoader {
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
        self.storage?.async.object(forKey: self.cacheKey, completion: { (res) in
            switch res {
            case .value(let rooms):
                handler(rooms)
            case .error(let error):
                GittkerLog.logCacheError(title: "Failed to prefetch suggested room cache", error: error)
            }
        })
        
        GitterApi.shared.getSuggestedRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            self.storage?.async.setObject(rooms, forKey: self.cacheKey, completion: { (_) in })
            handler(rooms)
        }
    }
}

class CachedRoomLoader: CachedLoader {
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
                GittkerLog.logCacheError(title: "Failed to fetch room loader cache", error: error)
                break
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

class CachedPrefetchRoomUsers: CachedLoader {
    typealias Handler = ([UserSchema]) -> Void
    typealias CodeType = [UserSchema]
    
    var diskConfig: DiskConfig
    var memoryConfig: MemoryConfig
    var storage: Storage<[UserSchema]>?
    
    var cacheKey: String
    var roomId: String
    
    init(cacheKey: String, roomId: String) {
        self.roomId = roomId
        self.cacheKey = cacheKey
        self.diskConfig = DiskConfig(name: self.cacheKey, expiry: .never)
        self.memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 100)
        
        self.storage = try? Storage<[UserSchema]>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: [UserSchema].self)
        )
    }
    
    func fetchData(then handler: @escaping Handler) {
        self.storage?.async.object(forKey: self.cacheKey, completion: { result in
            switch result {
              case .value(let users):
                handler(users)
              case .error(let error):
                GittkerLog.logCacheError(title: "Failed to prefetch room users cache", error: error)
            }
        })

        GitterApi.shared.listUsersInRoom(roomId: roomId, skip: 0) { (usersSchema) in
            self.storage?.async.setObject(usersSchema, forKey: self.cacheKey, completion: { _ in })
            handler(usersSchema)
        }
    }
    
    func fetchNewAndCache(then handler: @escaping Handler) {
        GitterApi.shared.listUsersInRoom(roomId: roomId, skip: 0) { (usersSchema) in
            self.storage?.async.setObject(usersSchema, forKey: self.cacheKey, completion: { _ in })
            handler(usersSchema)
        }
    }
}
