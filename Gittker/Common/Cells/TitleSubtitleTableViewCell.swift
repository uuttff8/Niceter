//
//  TitleSubtitileTableViewCell.swift
//  Gittker
//
//  Created by uuttff8 on 3/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class TitleSubtitleTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
