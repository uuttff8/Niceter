//
//  ClearCookies.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import WebKit

func ClearCookies(_ completionHandler: @escaping () -> Void) {
    URLCache.shared.removeAllCachedResponses()

    let date = Date(timeIntervalSince1970: 0)
    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: date, completionHandler: completionHandler)
}

