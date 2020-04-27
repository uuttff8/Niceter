//
//  NiceterLog.swift
//  Niceter
//
//  Created by uuttff8 on 4/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import Firebase
import Cache

class NiceterLog {
    static func logError(title: String, error: Error) {
        Analytics.logEvent(title, parameters: [
            AnalyticsParameterItemID: "id-\(title)",
            AnalyticsParameterItemName: title,
            AnalyticsParameterContentType: "cont",
            "error": error.localizedDescription,
        ])
    }
    
    static func logCacheError(title: String, error: Error) {
        NiceterLog.logError(title: "failed_cache", error: error)
    }
}
