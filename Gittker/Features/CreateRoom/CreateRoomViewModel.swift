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
        let nameItem = TableGroupedItem(text: "", type: .enterName, value: "")
        let permissionItems = [TableGroupedItem(text: "Private", type: .publicPrivate, value: ""),
                               TableGroupedItem(text: "Members can join this room", type: .privateMembers, value: "")]

        
        let nameSection = TableGroupedCreateRoomSection(section: .entername,
                                                        items: [nameItem],
                                                        footer: "",
                                                        grouped: true)
        
        let permissionsSection = TableGroupedCreateRoomSection(section: .permissions,
                                                        items: permissionItems,
                                                        footer: "When private, only people added to the room can join.",
                                                        grouped: true)
        
        
        self.dataSource?.data.value = [nameSection, permissionsSection]
    }
    
    
    func fetchAdminGroups() {
        GitterApi.shared.getAdminGroups { (groupSchema) in
            self.adminGroupsData.value = groupSchema
            
            let owned = groupSchema.map { (group) in
                TableGroupedItem(text: "", type: .ownedCommunities, value: "")
            }
            
            let ownedCommunities = TableGroupedCreateRoomSection(section: .ownedCommunities,
                                                                 items: owned, footer: "", grouped: true)
            self.dataSource?.data.value.append(ownedCommunities)
        }
    }
    
    func createRoom(roomName: String, community: GroupSchema, securityPrivate: Bool, privateMembers: Bool, completion: @escaping (Result<(), GitterApiErrors.CreateRoomError>) -> Void) {
        GitterApi.shared.createRoom(groupId: community.id, roomName: roomName, securityPrivate: securityPrivate, privateMembers: privateMembers) { (res) in
            completion(res)
        }
    }
}

final class CreateRoomTableDelegates: GenericDataSource<TableGroupedCreateRoomSection>, ASTableDataSource, ASTableDelegate {
    weak var coordinator: CreateRoomCoordinator?
    var adminGroups: [GroupSchema] = [GroupSchema]()
    public var selectedCommunity: GroupSchema?
    
    public var roomName: String? = nil
    public var isPrivateSwitchActive: Bool = false
    public var isPrivateMemberSwitchActive: Bool = false
    
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
            case .permissions:
                
                switch item.type {
                case .publicPrivate:
                    let cell = SwitchNodeCell(with: SwitchNodeCell.Content(title: "Private",
                                                                           isSwitcherOn: false,
                                                                           isSwitcherActive: true))
                    cell.switchChanged = { (isOn) in
                        self.isPrivateSwitchActive = isOn
                        tableNode.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
                    }
                    return cell
                case .privateMembers:
                    let cell = SwitchNodeCell(with: SwitchNodeCell.Content(title: "Members can join this room",
                                                                                         isSwitcherOn: false,
                                                                                         isSwitcherActive: self.isPrivateSwitchActive))
                    cell.switchChanged = { (isOn) in
                        self.isPrivateMemberSwitchActive = isOn
                    }
                    return cell
                default : return ASCellNode()
                }
            case .ownedCommunities:
                let model = self.adminGroups[indexPath.row]
                let cell = CreateRoomMarkedNodeCell(with: CreateRoomMarkedNodeCell.Content(title: model.name,
                                                                                           isSelected: self.selectedCommunity?.id == model.id))
                cell.selectionStyle = .none
                return cell
            case .entername:
                let content = TextFieldNodeCell.Content(defaultText: self.roomName)
                let cell = TextFieldNodeCell(with: content, delegate: self)
                return cell
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
        
        switch section.section {
        case .permissions:
            tableNode.deselectRow(at: indexPath, animated: true)
        case .ownedCommunities:
            let model = self.adminGroups[indexPath.row]
            selectedCommunity = model
            tableNode.reloadSections(IndexSet([2]), with: .none)
        case .entername:
            tableNode.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension CreateRoomTableDelegates: ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        self.roomName = editableTextNode.attributedText?.string
    }
}

