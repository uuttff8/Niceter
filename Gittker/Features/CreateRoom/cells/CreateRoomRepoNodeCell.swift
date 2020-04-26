//
//  CreateRoomRepoNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class CreateRoomRepoNodeCell: ASCellNode {
    
    private let titleNode = ASTextNode()
    
    private let content: RepoSchema
    
    // MARK: - Object life cycle
    init(with content: RepoSchema) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.buildNodeHierarchy()
    }
    
    // Internal Setup
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.name,
                                                           attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    

    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    // External Setup
    func drawPrivateRepoEmoji() {
        if content.private {
            self.titleNode.attributedText = NSAttributedString(string: self.content.name + " 🔒",
                                                               attributes: self.titleTextAttributes)
        }
    }
    

    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            HStackLayout(spacing: 10.0, justifyContent: .start, alignItems: .center) {
                titleNode
                    .flexShrink(1.0)
            }.padding(UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0))
        }
    }
}
