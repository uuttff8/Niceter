//
//  CreateRoomViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

struct CreateRoomViewModel {
    weak var dataSource : GenericDataSource<TableGroupedCreateRoomSection>?
    
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
        
        
        self.dataSource?.data.value = [name]
    }
}


class CreateRoomTableDelegates: GenericDataSource<TableGroupedCreateRoomSection>, ASTableDataSource, ASTableDelegate {
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
                return self.createCell(by: item.type)
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
        //        let item = section.items[indexPath.row]
        
        switch section.section {
        case .name:
            tableNode.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func createCell(by type: TableGroupedType) -> ASCellNode {
        switch type {
        case .community:
            return DefaultDisclosureNodeCell(with: DefaultDisclosureNodeCell.Content(title: "Community", subtitle: "Required"))
        case .roomName:
            return DefaultDisclosureNodeCell(with: DefaultDisclosureNodeCell.Content(title: "Room name", subtitle: "Required"))
        default:
            return ASCellNode()
        }
    }
}
