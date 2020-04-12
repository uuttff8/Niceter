//
//  DefaultDisclosureNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class DefaultDisclosureNodeCell: ASCellNode {
    struct Content {
        let title: String
        let subtitle: String
    }
    
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    
    private let content: DefaultDisclosureNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: DefaultDisclosureNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.setupSubtitleNode()
        self.buildNodeHierarchy()
        self.accessoryType = .disclosureIndicator
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private func setupSubtitleNode() {
        self.subtitleNode.attributedText = NSAttributedString(string: self.content.subtitle, attributes: self.titleTextAttributes)
        self.subtitleNode.maximumNumberOfLines = 1
        self.subtitleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode, subtitleNode].forEach { (node) in
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
                                          children: [self.titleNode, spacer, self.subtitleNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0), child: finalSpec)
    }

}
