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
                                          items:
            [TableGroupedProfile(text: userdata.displayName,
                                     type: .gitter,
                                     value: userdata.username,
                                     avatarUrl: userdata.avatarURL ?? "",
                                     user: userdata),
            ],
                                          footer: nil,
                                          grouped: true)
        
        let logout = TableGroupedSection(section: .logout,
                                         items:
            [TableGroupedItem(text:  "Logout",
                              type: .noUrl,
                              value: "")
            ],
                                         footer: nil,
                                         grouped: true)
        
        
        self.dataSource?.data.value = [profile, logout]
    }
}

class SettingsTableDelegates: GenericDataSource<TableGroupedSection>, ASTableDataSource, ASTableDelegate {
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
                guard let item2 = item as? TableGroupedProfile else { return ASCellNode() }
                cell = SettingsProfileNodeCell(with: item2.user)
            case .logout:
                cell = SettingsButtonNodeCell(with: SettingsButtonNodeCell.Content(title: item.text))
                
            default:
                cell = ASCellNode()
            }
            
            return cell
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
        case .profile:
            print("LOL")
            tableNode.deselectRow(at: indexPath, animated: true)
        case .logout:
            self.logout()
            tableNode.deselectRow(at: indexPath, animated: true)
            
        default:
            break
        }
        
    }
    
    private func logout() {
        LoginData.shared.logout()
        
        // Safety: we use only one window
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        let root = ASNavigationController()
        window.rootViewController = root
        root.setNavigationBarHidden(true, animated: false)
        let child = LoginAuthCoordinator(navigationController: root)
        child.start()
        
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.3

        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
        { completed in
            
        })
    }

}
