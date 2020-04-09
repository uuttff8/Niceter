//
//  SettingsCache.swift
//  Gittker
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

class CachedUserLoader: CachedLoaderProtocol {
    typealias Handler = (UserSchema) -> Void
    typealias CodeType = UserSchema
    
    var diskConfig: DiskConfig
    var memoryConfig: MemoryConfig
    var storage: Storage<UserSchema>?
    
    var cacheKey: String

    init(cacheKey: String) {
        self.cacheKey = cacheKey
        self.diskConfig = DiskConfig(name: self.cacheKey, expiry: .seconds(86400))
        self.memoryConfig = MemoryConfig(expiry: .seconds(86400), countLimit: 10, totalCostLimit: 10) // 24 hours
        
        self.storage = try? Storage<UserSchema>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: UserSchema.self)
        )
    }
    
    func fetchData(then handler: @escaping CachedLoader<UserSchema>.Handler) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cached = try? self.storage?.object(forKey: self.cacheKey) {
                handler(cached)
            }
        }

        GitterApi.shared.getUser(username: self.cacheKey) { (userSchema) in
            guard let user = userSchema else { return }
            try? self.storage?.setObject(user, forKey: self.cacheKey)
            handler(user)
        }
    }
}
