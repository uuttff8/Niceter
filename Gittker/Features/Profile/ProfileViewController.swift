//
//  ProfileViewController.swift
//  Gittker
//
//  Created by uuttff8 on 4/9/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ProfileViewController: ASViewController<ASTableNode> {
    weak var coordinator: ProfileCoordinator?
    
    private var profileList = [UserSchema]()
    private var username: String
    
    private var tableNode: ASTableNode {
        return node
    }
    
    init(coordinator: ProfileCoordinator, username: String) {
        self.coordinator = coordinator
        self.username = username
        super.init(node: ASTableNode(style: .insetGrouped))
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        tableNode.view.separatorStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = username
    }
}

extension ProfileViewController: ASTableDelegate {
    
}


extension ProfileViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let cell = ProfileMainNodeCell(with: nil)
            
            CachedUserLoader.init(cacheKey: self.username)
                .fetchData { (user) in
                    print(user)
                    cell.configureCell(with: user)
            }
            
            return cell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
