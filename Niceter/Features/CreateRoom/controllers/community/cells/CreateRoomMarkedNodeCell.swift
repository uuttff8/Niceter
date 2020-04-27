//
//  CreateRoomMarkedNodeCell.swift
//  Niceter
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomMarkedNodeCell: ASCellNode {
    struct Content {
        let title: String
        let isSelected: Bool
    }
    
    private let titleNode = ASTextNode()
    
    private let content: CreateRoomMarkedNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: CreateRoomMarkedNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.buildNodeHierarchy()
        accessoryType = content.isSelected ? .checkmark : .none
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        self.titleNode.style.flexShrink = 1
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [self.titleNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0), child: finalSpec)
    }
}
