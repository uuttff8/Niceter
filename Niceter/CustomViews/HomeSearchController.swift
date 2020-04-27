//
//  HomeSearchController.swift
//  Niceter
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeSearchController: UISearchController {
    
    override func loadView() {
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
