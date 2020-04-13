//
//  GroupSchema.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
public struct GroupSchema: Codable {
    let id: String
    let name: String
    let uri: String
    let homeUri: String
    let backedBy: Self.BackedBy?
    let avatarUrl: String
    
    @frozen
    public struct BackedBy: Codable {
        let type: String?
        let linkPath: String?
    }    
}
