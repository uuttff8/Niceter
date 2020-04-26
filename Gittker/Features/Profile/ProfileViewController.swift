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
    
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var profileList = [UserSchema]()
    private var username: String
    private var currentUser: UserSchema?
    
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
        self.title = username
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.removeDependency(coordinator)
    }
}

extension ProfileViewController: ASTableDataSource, ASTableDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return ProfileTableSection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let section = ProfileTableSection.allCases[indexPath.section]
            
            switch section {
            case .info:
                let cell = ProfileMainNodeCell(with: nil)
                
                CachedUserLoader.init(cacheKey: self.username)
                    .fetchData { (user) in
                        cell.configureCell(with: user)
                        self.currentUser = user
                }
                
                return cell
            case .actions:
                let cell = SettingsButtonNodeCell(with: SettingsButtonNodeCell.Content(title: "Send a message".localized()), state: .default)
                return cell
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let section = ProfileTableSection.allCases[indexPath.section]
        
        switch section {
        case .actions:
            tableNode.deselectRow(at: indexPath, animated: true)
            
            switch coordinator?.currentFlow {
            case .fromSearch:
                self.navigationController?.popViewController(animated: true)
            case .fromChat:
                guard var currentUser: UserSchema = currentUser else { return }
                guard let users = ShareData().currentlyJoinedUsers else { return }
                
                var isJoined: Bool = false
                
                if let index = users.firstIndex(where: { $0.name == currentUser.displayName }) {
                    isJoined = true
                    currentUser.id = users[index].id // user id is not equal to room id
                }
                
                var intermediate = currentUser.toIntermediate()
                intermediate.avatarUrl = self.currentUser?.getGitterImage()
                coordinator?.showChat(intermediate: intermediate, isJoined: isJoined)
                
            default: break
            }
        default: break
        }
    }
}

private enum ProfileTableSection: CaseIterable {
    case info
    case actions
}
