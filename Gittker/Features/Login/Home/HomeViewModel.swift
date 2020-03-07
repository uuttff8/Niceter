//
//  HomeViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class HomeViewModel {
    
    open var model: RoomSchema?
    
    func getRooms() {
        GitterApi.shared.getRooms { (rooms) in
            
        }
    }
}

