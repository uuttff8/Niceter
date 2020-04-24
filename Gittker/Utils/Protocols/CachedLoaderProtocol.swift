//
//  CachedLoader.swift
//  Gittker
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Cache

protocol CachedLoader {
    associatedtype Handler
    associatedtype CodeType
    
    var diskConfig: DiskConfig { get set }
    var memoryConfig: MemoryConfig { get set }
    var storage: Storage<CodeType>? { get set }
    
    var cacheKey: String { get set }
    
    func fetchData(then handler: Handler)
    func fetchNewAndCache(then handler: Handler)
    func deleteAllData()
}

extension CachedLoader {
    func fetchNewAndCache(then handler: Handler) { }
    func deleteAllData() {
        storage?.async.removeAll(completion: { (res) in
            switch res {
            case .error(let error):
                GittkerLog.logCacheError(title: "removing data failed", error: error as! StorageError)
            default: break
            }
        })
    }
}
