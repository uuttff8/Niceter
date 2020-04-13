//
//  CreateRoomViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomViewModel {
    weak var dataSource : GenericDataSource<TableGroupedCreateRoomSection>?
    
    var adminGroupsData = DynamicValue<[GroupSchema]>([])
    
    init(dataSource : GenericDataSource<TableGroupedCreateRoomSection>?) {
        self.dataSource = dataSource
    }
    
    func fetchDataSource() {
        let name = TableGroupedCreateRoomSection(section: .name,
                                                 items:
            [TableGroupedItem(text:  "Community",
                              type: .community,
                              value: ""),
             TableGroupedItem(text: "Room Name",
                              type: .roomName,
                              value: "")
            ],
                                                 footer: "Your room will be ...",
                                                 grouped: true)
        
        let permissions = TableGroupedCreateRoomSection(section: .permissions,
                                                        items: [
                                                            TableGroupedItem(text: "Permission",
                                                                             type: .publicPrivate,
                                                                             value: "")
                                                            ],
                                                        footer: "Some permission",
                                                        grouped: true)
        
        self.dataSource?.data.value = [name, permissions]
    }
    
    
    func fetchAdminGroups() {
        GitterApi.shared.getAdminGroups { (groupSchema) in
            self.adminGroupsData.value = groupSchema
        }
    }
}

class CreateRoomTableDelegates: GenericDataSource<TableGroupedCreateRoomSection>, ASTableDataSource, ASTableDelegate {
    weak var coordinator: CreateRoomCoordinator?
    var adminGroups: [GroupSchema] = [GroupSchema]()
    
    var subtitleComm = "Required"
    var subtitleName = "Required"
    
    init(with coord: CreateRoomCoordinator) {
        self.coordinator = coord
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self.data.value.count
    }
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.data.value[section].items.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            
            let section = self.data.value[indexPath.section]
            let item = section.items[indexPath.row]
            
            switch section.section {
            case .name:
                return self.createNameCell(by: item)
            case .permissions:
                return SwitchNodeCell(with: SwitchNodeCell.Content(title: "Private", isSwitcherOn: false))
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        node.setNeedsDisplay()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.data.value[section]
        
        return section.section.description
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.data.value[section]
        
        return section.footer
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let section = self.data.value[indexPath.section]
        let item = section.items[indexPath.row]
        
        switch section.section {
        case .name:
            
            switch item.type {
            case .community:
                coordinator?.showCommunityPick(adminGroups: adminGroups) { (group) in
                    self.subtitleComm = group.name
                    tableNode.reloadData()
                }
            case .roomName:
                coordinator?.showEnteringName { (name: String) in
                    self.subtitleName = name
                    tableNode.reloadData()
                }
            default: break
            }
            
            
            tableNode.deselectRow(at: indexPath, animated: true)
        case .permissions:
            tableNode.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func createNameCell(by item: TableGroupedItemProtocol) -> ASCellNode {
        switch item.type {
        case .community:
            return DefaultDisclosureNodeCell(with: DefaultDisclosureNodeCell.Content(title: "Community", subtitle: subtitleComm))
        case .roomName:
            return DefaultDisclosureNodeCell(with: DefaultDisclosureNodeCell.Content(title: "Room name", subtitle: subtitleName))
        default:
            return ASCellNode()
        }
    }
}
