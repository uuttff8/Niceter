//
//  RoomTableNode.swift
//  Gittker
//
//  Created by uuttff8 on 3/21/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

struct RoomContent {
    let avatarUrl: String
    let title: String
    let subtitle: String
}

extension ASImageNode {
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

class RoomTableNode: ASCellNode {
    
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 64, height: 64)
    }()
    
    private let room: RoomContent
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with room: RoomContent) {
        self.room = room
        
        super.init()
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
        setupSubtitleNode()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: room.avatarUrl)
        self.imageNode.style.preferredSize = self.imageSize
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.room.title, attributes: self.titleTextAttributes())
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
    }
    
    private func setupSubtitleNode() {
        self.subtitleNode.attributedText = NSAttributedString(string: self.room.subtitle, attributes: self.subtitleTextAttributes())
        self.subtitleNode.maximumNumberOfLines = 2
        self.subtitleNode.truncationMode = .byTruncatingTail
    }
    
    private var subtitleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
    }
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        self.addSubnode(imageNode)
        self.addSubnode(titleNode)
        self.addSubnode(subtitleNode)
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0, y: 0.0, width: self.calculatedSize.width, height: separatorHeight)
        
        imageNode.setRounded()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        let titleSubtitleSpec = ASStackLayoutSpec(direction: .vertical,
                                                  spacing: 2.0,
                                                  justifyContent: .start,
                                                  alignItems: .stretch,
                                                  children: [self.titleNode, self.subtitleNode])
        
        titleSubtitleSpec.style.flexShrink = 1
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: [self.imageNode, titleSubtitleSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), child: finalSpec)
    }
}
