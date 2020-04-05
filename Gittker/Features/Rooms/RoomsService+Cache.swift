//
//  RoomsService.swift
//  Gittker
//
//  Created by uuttff8 on 3/30/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

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

class CachedRoomLoader: CachedLoader<[RoomSchema]> {
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
