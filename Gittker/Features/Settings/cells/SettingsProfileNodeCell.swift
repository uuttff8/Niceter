//
//  SettingsProfileNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SettingsProfileNodeCell: ASCellNode {
    struct Content {
        let title: String
        let avatarUrl: String?
    }
    
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 50, height: 50)
    }()
    
    private let content: SettingsProfileNodeCell.Content
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    private let gitInfoNode = ASTextNode()
    
    private let locationNode = ProfileAdditionalInfoNode(image: UIImage(systemName: "location")!)
    private let emailNode = ProfileAdditionalInfoNode(image: UIImage(systemName: "envelope")!)
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with content: SettingsProfileNodeCell.Content) {
        self.content = content
        
        super.init()
        selectionStyle = .none
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: self.content.avatarUrl ?? "")
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
    }()
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        self.addSubnode(imageNode)
        self.addSubnode(titleNode)
        self.addSubnode(separatorNode)
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
                                          children: [self.imageNode, self.titleNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0), child: finalSpec)
    }
}
