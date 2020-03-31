//
//  SettingsButtonNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 3/31/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SettingsButtonNodeCell: ASCellNode {
    struct Content {
        let title: String
    }
    
    private let titleNode = ASTextNode()
    private let separatorNode = ASDisplayNode()
    
    private let content: SettingsButtonNodeCell.Content
    
    // MARK: - Object life cycle
    
    init(with content: SettingsButtonNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.buildNodeHierarchy()
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.systemRed, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
    }()
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        [titleNode, separatorNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0, y: 0.0, width: self.calculatedSize.width, height: separatorHeight)
        self.separatorNode.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [self.titleNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0), child: finalSpec)
    }

}
