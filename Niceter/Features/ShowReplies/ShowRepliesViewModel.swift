//
//  ShowRepliesViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 7/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ShowRepliesViewModel {
    private let parentId: String
    private let roomRecreates: [RoomRecreateSchema]
    
    init (roomRecreates: [RoomRecreateSchema]) {
        self.roomRecreates = roomRecreates
        self.parentId = roomRecreates[0].parentId ?? ""
    }
}
