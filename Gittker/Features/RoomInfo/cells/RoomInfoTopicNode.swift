//
//  RoomInfoTopicNode.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoTopicNode: ASCellNode {
    private let content: String
    
    private let titleNode = ASTextNode()
    
    // MARK: - Object life cycle
    
    init(with content: String) {
        self.content = content
        super.init()
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.systemBackground
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setuping Nodes
    private func setupNodes() {
        
        setupTitleNode()
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content, attributes: Dictionary.defaultTitleAttributes(size: 16))
        self.titleNode.maximumNumberOfLines = 0
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 16.0), child: self.titleNode)

    }
}

