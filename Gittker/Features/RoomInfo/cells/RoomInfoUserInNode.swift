//
//  RoomInfoUserInNode.swift
//  Gittker
//
//  Created by uuttff8 on 4/19/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class RoomInfoUserInNode: ASCellNode {
    struct Content {
        let title: String
        let image: String
    }
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 34, height: 34)
    }()
    
    private let titleNode = ASTextNode()
    private let imageNode = ASNetworkImageNode()
    private let separatorNode = ASDisplayNode()
    
    private let content: RoomInfoUserInNode.Content
    
    // MARK: - Object life cycle
    init(with content: RoomInfoUserInNode.Content) {
        self.content = content
        
        super.init()
        
        self.backgroundColor = UIColor.systemBackground
        
        self.setupTitleNode()
        self.setupImageNode()
        self.buildNodeHierarchy()
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title,
                                                           attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: self.content.image)
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRoundingType = .precomposited
        self.imageNode.backgroundColor = UIColor.systemBackground
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode, imageNode, separatorNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: self.calculatedSize.width,
                                          height: separatorHeight)
        self.separatorNode.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            HStackLayout(spacing: 10.0, justifyContent: .start, alignItems: .center) {
                imageNode
                titleNode
            }.padding(UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 16.0))
        }
    }
}
