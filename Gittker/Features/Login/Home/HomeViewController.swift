//
//  HomeViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Storyboarded {

    weak var coordinator: HomeCoordinator?
    
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Conversations"
        
        viewModel.getRooms()
        
    }
    
    
}
