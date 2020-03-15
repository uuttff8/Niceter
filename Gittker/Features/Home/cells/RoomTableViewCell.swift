//
//  RoomTableViewCell.swift
//  Gittker
//
//  Created by uuttff8 on 3/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import Nuke

class RoomTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var cellImageView: UIImageView! {
        didSet {
            cellImageView.layer.cornerRadius = cellImageView.frame.size.width / 2;
            cellImageView.clipsToBounds = true
        }
    }
    
    func initialize(with room: RoomSchema) {
        title.text = room.name
        subtitle.text = room.topic
        Nuke.loadImage(with: URL(string: room.avatarUrl!)!, into: cellImageView)
    }
}
