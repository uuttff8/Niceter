//
//  SettingsViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

struct SettingsViewModel {
    weak var dataSource : GenericDataSource<TableGroupedSection>?
    
    init(dataSource : GenericDataSource<TableGroupedSection>?) {
        self.dataSource = dataSource
    }
    
    func fetchDataSource() {
        guard let userdata = ShareData().userdata else { return }
        
        let profile = TableGroupedSection(section: .profile,
                                          items: [TableGroupedContributor(text: userdata.displayName,
                                                                          type: .gitter,
                                                                          value: userdata.username,
                                                                          avatarUrl: userdata.avatarURL ?? "")],
                                          footer: nil,
                                          grouped: false)
        
        
        self.dataSource?.data.value = [profile]
    }
}

class SettingsDataSource: GenericDataSource<TableGroupedSection>, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self.data.value.count
    }
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.data.value[section].items.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            var cell: ASCellNode
            
            let section = self.data.value[indexPath.section]
            let item = section.items[indexPath.row]
            
            switch section.section {
            case .profile:
                let item2 = item as? TableGroupedContributor
                cell = SettingsProfileNodeCell(with: ProfileNodeCellContent(title: item.text, avatarUrl: item2?.avatarUrl))
                cell.selectionStyle = .none
            default:
                cell = ASCellNode()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setNeedsDisplay()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.data.value[section]
        
        return section.section.description
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.data.value[section]
        
        return section.footer
    }
}
