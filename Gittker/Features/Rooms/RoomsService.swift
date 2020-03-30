//
//  RoomsService.swift
//  Gittker
//
//  Created by uuttff8 on 3/30/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

enum RoomsService {
    static func share(room: RoomSchema,
                      in viewController: UIViewController) {
        guard let uri = room.uri else { return }
        let text = "https://gitter.im/\(uri)?utm_source=share-link&utm_medium=link&utm_campaign=share-link"
        
        let activityViewController = UIActivityViewController(
            activityItems: [text], applicationActivities: nil)
        
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
}
