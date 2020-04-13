//
//  CreateRoomNameViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomNameViewModel {
    var reloadRepos: (() -> Void)? = nil
    
    var repos = [RepoSchema]() {
        didSet {
            reloadRepos?()
        }
    }
    
    func getRepos() {
        GitterApi.shared.getRepos { (reposSchema) in
            self.repos = reposSchema
        }
    }
}
