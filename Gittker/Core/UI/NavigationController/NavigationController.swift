//
//  NavigationController.swift
//  Gittker
//
//  Created by uuttff8 on 4/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class NavigationController: ASNavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.createPoppingFromView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
