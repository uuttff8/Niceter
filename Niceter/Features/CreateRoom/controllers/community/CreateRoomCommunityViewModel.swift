//
//  CreateRoomCommunityViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class CreateRoomCommunityViewModel {
    var groups = DynamicValue<[GroupSchema]>([])
    
    func fetchAdminGroups(with adminGroups: [GroupSchema]) {
        self.groups.value = adminGroups
    }
}
