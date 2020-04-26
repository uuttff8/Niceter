//
//  DefaultDisclosureNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class DefaultDisclosureNodeCell: ASCellNode {
    struct Content {
        let title: String
        let subtitle: String
    }
    
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    
    private let content: DefaultDisclosureNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: DefaultDisclosureNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.setupSubtitleNode()
        self.buildNodeHierarchy()
        self.accessoryType = .disclosureIndicator
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title,
                                                           attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private func setupSubtitleNode() {
        self.subtitleNode.attributedText = NSAttributedString(string: self.content.subtitle,
                                                              attributes: self.titleTextAttributes)
        self.subtitleNode.maximumNumberOfLines = 1
        self.subtitleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode, subtitleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            HStackLayout(spacing: 10.0, justifyContent: .start, alignItems: .center) {
                titleNode
                    .flexShrink(1.0)
                ASLayoutSpec()
                    .flexGrow(1.0)
                subtitleNode
            }.padding(UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0))
        }
    }
}
