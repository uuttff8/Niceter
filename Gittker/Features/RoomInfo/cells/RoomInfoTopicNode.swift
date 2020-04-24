//
//  RoomInfoTopicNode.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class RoomInfoTopicNode: ASCellNode {
    private let content: String
    
    private let titleNode = ASTextNode()
    private let separatorNodeTop = ASDisplayNode()
    private let separatorNodeBottom = ASDisplayNode()
    
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
        [titleNode, separatorNodeTop, separatorNodeBottom].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // Layout
    override func layout() {
        super.layout()
        
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNodeTop.frame = CGRect(x: 0.0, y: 0.0, width: self.calculatedSize.width, height: separatorHeight)
        self.separatorNodeBottom.frame = CGRect(x: 0.0,
                                                y: self.calculatedSize.height - 0.5,
                                                width: self.calculatedSize.width,
                                                height: separatorHeight)
        
        self.separatorNodeTop.backgroundColor = UIColor.separator
        self.separatorNodeBottom.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            titleNode
                .flexShrink(1.0)
                .padding(UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 16.0))
        }
    }
}

