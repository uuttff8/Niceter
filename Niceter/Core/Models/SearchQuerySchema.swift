//
//  SearchQuerySchema.swift
//  Niceter
//
//  Created by uuttff8 on 3/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
public struct SearchQuerySchema<T: Codable>: Codable {
    let results: [T]
}
