//
//  SuggestemRoomCellNode.swift
//  Gittker
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class SuggestedRoomTableNode: ASCellNode {
    struct Content {
        let title: String
        let avatarUrl: String
        let roomId: String
    }
    
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 40, height: 40)
    }()
    
    private let room: SuggestedRoomTableNode.Content
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with room: SuggestedRoomTableNode.Content) {
        self.room = room
        
        super.init()
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: room.avatarUrl)
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.room.title, attributes: self.titleTextAttributes)
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
        LayoutSpec {
            HStackLayout(spacing: 10.0, alignItems: .center) {
                imageNode
                titleNode
                    .flexShrink(1.0)
            }.padding(UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0))
        }
    }
}
