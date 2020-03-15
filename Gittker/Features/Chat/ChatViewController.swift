//
//  ChatViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, Storyboarded {

    open var roomId: String?
    
    weak var coordinator: ChatCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(roomId)
    }
}
