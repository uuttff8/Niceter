//
//  RoomInfoGeneralInfoNode.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class RoomInfoGeneralInfoNode: ASCellNode {
    private lazy var imageSize: CGSize = {
        return CGSize(width: 96, height: 96)
    }()
    
    private let content: RoomSchema
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with content: RoomSchema) {
        self.content = content
        super.init()
        
        automaticallyManagesSubnodes = true
        
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
        [imageNode, titleNode, separatorNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // Layout
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0,
                                          y: self.calculatedSize.height - 0.5,
                                          width: self.calculatedSize.width,
                                          height: separatorHeight)
        self.separatorNode.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(spacing: 10.0, justifyContent: .center, alignItems: .center) {
                imageNode
                titleNode
                    .flexShrink(1.0)
            }
            .padding(UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        }
    }
}
