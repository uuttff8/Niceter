//
//  SearchQuerySchema.swift
//  Gittker
//
//  Created by uuttff8 on 3/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct SearchQuerySchema: Codable {
    let results: [RoomSchema]
}
