//
//  RoomInfoGeneralInfoNode.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoGeneralInfoNode: ASCellNode {
    private lazy var imageSize: CGSize = {
        return CGSize(width: 96, height: 96)
    }()
    
    private let content: RoomSchema
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    
    // MARK: - Object life cycle
    
    init(with content: RoomSchema) {
        self.content = content
        super.init()
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.systemBackground
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setuping Nodes
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
    }
    
    private func setupImageNode() {
        imageNode.url = URL(string: content.avatarUrl!)!
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.name ?? "", attributes: Dictionary.boldTitleAttributes(size: 23))
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [imageNode, titleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        let finalSpec = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 10.0,
                                          justifyContent: .center,
                                          alignItems: .center,
                                          children: [self.imageNode, self.titleNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0), child: finalSpec)

    }
}
