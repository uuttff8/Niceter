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

class CachedRoomLoader: CachedLoaderProtocol {
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
                print(error)
            }
        })

        GitterApi.shared.getRooms { (roomsSchema) in
            guard let rooms = roomsSchema else { return }
            self.storage?.async.setObject(rooms, forKey: self.cacheKey, completion: { _ in
                handler(rooms)
            })
        }
    }
    
    func fetchNewAndCache(then handler: @escaping Handler) {
        GitterApi.shared.getRooms { (roomSchemaList) in
            guard let rooms = roomSchemaList else { return }
            try? self.storage?.setObject(rooms, forKey: self.cacheKey)
            handler(rooms)
        }
    }
}
