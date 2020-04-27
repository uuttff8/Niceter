//
//  CreateRoomNameViewModel.swift
//  Niceter
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomNameViewModel {
    var repos = DynamicValue<[RepoSchema]>([])
    
    func getRepos() {
        GitterApi.shared.getRepos { (reposSchema) in
            self.repos.value = reposSchema
        }
    }
}
