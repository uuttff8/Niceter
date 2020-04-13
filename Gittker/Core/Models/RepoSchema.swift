//
//  RepoSchema.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct RepoSchema: Codable {
    let id: Int
    let type: String
    let name: String
    let description: String?
    let absoluteUri: String
    let uri: String
    let `private`: Bool
    let exists: Bool
    let avatar_url: String
}

//{
//  "type": "GH_REPO",
//  "id": 191054467,
//  "name": "uuttff8/website",
//  "description": "Flutter web site",
//  "absoluteUri": "https://github.com/uuttff8/website",
//  "uri": "uuttff8/website",
//  "private": false,
//  "exists": false,
//  "avatar_url": "https://avatars3.githubusercontent.com/u/40335671?v=4"
//},

