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
        let nameItems = [TableGroupedItem(text: "", type: .enterName, value: ""),
                        TableGroupedItem(text: "", type: .enterTopic, value: "")]
        let permissionItems = [TableGroupedItem(text: "Private".localized(), type: .publicPrivate, value: ""),
                               TableGroupedItem(text: "Members can join this room".localized(), type: .privateMembers, value: "")]

        
        let nameSection = TableGroupedCreateRoomSection(section: .entername,
                                                        items: nameItems,
                                                        footer: "",
                                                        grouped: true)
        
        let permissionsSection = TableGroupedCreateRoomSection(section: .permissions,
                                                        items: permissionItems,
                                                        footer: "When private, only people added to the room can join.".localized(),
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
                                                                 items: owned,
                                                                 footer: "You must select a community for your room".localized(),
                                                                 grouped: true)
            self.dataSource?.data.value.append(ownedCommunities)
        }
    }
    
    func createRoom(
        roomName: String,
        topic: String?,
        community: GroupSchema,
        securityPrivate: Bool,
        privateMembers: Bool,
        completion: @escaping (Result<(), GitterApiErrors.CreateRoomError>) -> Void)
    {
        GitterApi.shared.createRoom(groupId: community.id,
                                    roomName: roomName,
                                    topic: topic,
                                    securityPrivate: securityPrivate,
                                    privateMembers: privateMembers) { (res) in
            completion(res)
        }
    }
}

final class CreateRoomTableDelegates: GenericDataSource<TableGroupedCreateRoomSection>, ASTableDataSource, ASTableDelegate {
    
    // MARK: - Properties
    private weak var coordinator: CreateRoomCoordinator?
    
    public var adminGroups: [GroupSchema] = [GroupSchema]()
    public var selectedCommunity: GroupSchema?
    public var roomName: String? = nil
    public var topicDescription: String? = nil
    public var isPrivateSwitchActive: Bool = false
    public var isPrivateMemberSwitchActive: Bool = false
    
    // for delegate identifying
    private var roomNameTextField: ASEditableTextNode?
    private var topicTextField: ASEditableTextNode?
    
    // MARK: - Init
    init(with coord: CreateRoomCoordinator) {
        self.coordinator = coord
    }

    // MARK: Delegate And DataSource
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
            case .entername:
                return self.createEnterCells(item)
            case .permissions:
                return self.createPermissionCells(item, tableNode: tableNode)
            case .ownedCommunities:
                let model = self.adminGroups[indexPath.row]
                let cell = CreateRoomMarkedNodeCell(with: CreateRoomMarkedNodeCell.Content(title: model.name,
                                                                                           isSelected: self.selectedCommunity?.id == model.id))
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        node.setNeedsDisplay()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.data.value[section].section.description
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.data.value[section].footer
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

// MARK: - Creating Cells
extension CreateRoomTableDelegates {
    private func createPermissionCells(_ item: TableGroupedItemProtocol, tableNode: ASTableNode) -> ASCellNode {
        switch item.type {
        case .publicPrivate:
            let cell = SwitchNodeCell(with: SwitchNodeCell.Content(title: "Private".localized(),
                                                                   isSwitcherOn: false,
                                                                   isSwitcherActive: true))
            cell.switchChanged = { (isOn) in
                self.isPrivateSwitchActive = isOn
                tableNode.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
            }
            return cell
        case .privateMembers:
            let cell = SwitchNodeCell(with: SwitchNodeCell.Content(title: "Members can join this room".localized(),
                                                                   isSwitcherOn: false,
                                                                   isSwitcherActive: self.isPrivateSwitchActive))
            cell.switchChanged = { (isOn) in
                self.isPrivateMemberSwitchActive = isOn
            }
            return cell
        default : return ASCellNode()
        }
    }
    
    private func createEnterCells(_ item: TableGroupedItemProtocol) -> ASCellNode {
        switch item.type {
        case .enterName:
            let content = TextFieldNodeCell.Content(placeholder: "Enter a room name".localized(),
                                                    defaultText: self.roomName,
                                                    height: nil)
            let cell = TextFieldNodeCell(with: content, delegate: self)
            self.roomNameTextField = cell.textFieldNode
            return cell
        case .enterTopic:
            let content = TextFieldNodeCell.Content(placeholder: "Enter a topic (optional)".localized(),
                                                    defaultText: self.roomName,
                                                    height: 58)
            let cell = TextFieldNodeCell(with: content, delegate: self)
            self.topicTextField = cell.textFieldNode
            return cell
        default: return ASCellNode()
        }
    }
}

// MARK: - ASEditableTextNodeDelegate
extension CreateRoomTableDelegates: ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        switch editableTextNode {
        case topicTextField:
            self.topicDescription = editableTextNode.attributedText?.string
        case roomNameTextField:
            self.roomName = editableTextNode.attributedText?.string
        default:
            break
        }
    }
}

