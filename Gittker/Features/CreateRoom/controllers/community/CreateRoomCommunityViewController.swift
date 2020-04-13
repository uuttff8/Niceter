//
//  CreateRoomCommunityViewController.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import SafariServices

class CreateRoomCommunityViewController: ASViewController<ASTableNode> {
    let viewModel: CreateRoomCommunityViewModel = CreateRoomCommunityViewModel()
    
    weak var coordinator: CreateRoomCoordinator?
    
    private var tableNode: ASTableNode {
        return node
    }
    private var groupSelected: ((Bool) -> Void)? = nil
    
    open var selectedCommunity: GroupSchema?
    open var completionHandler: ((GroupSchema, _ ghRepoEnabled: Bool) -> Void)? = nil
    
    init(coordinator: CreateRoomCoordinator, adminGroups: [GroupSchema]) {
        self.coordinator = coordinator
        super.init(node: ASTableNode(style: .grouped))
        self.tableNode.dataSource = self
        self.tableNode.delegate = self
        
        self.viewModel.fetchAdminGroups(with: adminGroups)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CreateRoomCommunityViewController: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return CreateRoomCommunitySection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let section = CreateRoomCommunitySection.allCases[indexPath.section]
        return {
            var returnCell = ASCellNode()
            switch section {
            case .adminGroups:
                let model = self.viewModel.groups.value[indexPath.row]
                let cell = CreateRoomMarkedNodeCell(with: CreateRoomMarkedNodeCell.Content(title: model.name,
                                                                                           isSelected: self.selectedCommunity?.id == model.id))
                cell.selectionStyle = .none
                
                returnCell = cell
            case .createCommunity:
                let cell = SettingsButtonNodeCell(with: SettingsButtonNodeCell.Content(title: "Create new community"), state: .default)
                cell.accessoryType = .disclosureIndicator
                returnCell = cell
            }
            
            return returnCell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let section = CreateRoomCommunitySection.allCases[indexPath.section]
        
        switch section {
        case .adminGroups:
            let model = self.viewModel.groups.value[indexPath.row]
            selectedCommunity = model
            completionHandler?(selectedCommunity!, true)
            
            tableNode.reloadData()
        case .createCommunity:
            guard let url = URL(string: "https://gitter.im/home/explore#createcommunity") else { return }
            UIApplication.shared.open(url)
        }
        
        tableNode.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let section = CreateRoomCommunitySection.allCases[section]
        
        switch section {
        case .adminGroups:
            return self.viewModel.groups.value.count
        case .createCommunity:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = CreateRoomCommunitySection.allCases[section]
        return section.footerTitle
    }
    
}

private enum CreateRoomCommunitySection: Int, CaseIterable {
    case adminGroups
    case createCommunity
    
    var footerTitle: String {
        switch self {
        default: return ""
        }
    }
}
