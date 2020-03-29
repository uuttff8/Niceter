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
    let unreadItems: Int
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
    private let unreadNodeText = ASTextNode()
    private let unreadNode = ASDisplayNode()
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
        setupUnread()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: room.avatarUrl)
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRoundingType = .precomposited
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
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
    
    private func setupUnread() {
        if room.unreadItems > 0 {
            self.unreadNodeText.attributedText = NSAttributedString(string: String(self.room.unreadItems), attributes: [.foregroundColor: UIColor.label])
            self.unreadNode.cornerRadius = 10
            self.unreadNode.backgroundColor = UIColor.tertiarySystemFill
        }
    }
    
    private var subtitleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
    }
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        [imageNode, titleNode, subtitleNode, unreadNode, unreadNodeText, separatorNode].forEach { (node) in
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
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        
        self.unreadNode.style.preferredSize = CGSize(width: 40, height: 30)
        self.titleNode.style.flexShrink = 1
        let titleSubtitleSpec = ASStackLayoutSpec(direction: .vertical,
                                                  spacing: 2.0,
                                                  justifyContent: .start,
                                                  alignItems: .stretch,
                                                  children: [self.titleNode, self.subtitleNode])
        
        titleSubtitleSpec.style.flexShrink = 1
        
        let unreadInsetSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.unreadNodeText)
        let unreadOverlaySpec = ASOverlayLayoutSpec(child: self.unreadNode, overlay: unreadInsetSpec)
        let unreadStack = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .center, children: [unreadOverlaySpec])
        
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: [self.imageNode, titleSubtitleSpec, spacer, unreadStack])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 16.0), child: finalSpec)
    }
}
