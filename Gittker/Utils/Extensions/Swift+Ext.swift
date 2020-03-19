//
//  Swift+Ext.swift
//  Gittker
//
//  Created by uuttff8 on 3/19/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

extension Dictionary {
    var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
