//
//  HomeViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/5/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeViewModel {
    weak var dataSource : GenericDataSource<RoomSchema>?
    
    init(dataSource : GenericDataSource<RoomSchema>?) {
        self.dataSource = dataSource
    }
    
    func fetchRooms() {
        GitterApi.shared.getRooms { (rooms) in
            guard let rooms = rooms else { return }
            
            self.dataSource?.data.value = rooms
        }
    }
}

class HomeDataSource: GenericDataSource<RoomSchema>, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cell(forRowAt: indexPath) as TitleSubtitleTableViewCell
        
        cell.title.text = data.value[indexPath.item].name
        cell.subtitle.text = data.value[indexPath.item].topic
        
        cell.selectionStyle = .none
        
        return cell
    }
}


