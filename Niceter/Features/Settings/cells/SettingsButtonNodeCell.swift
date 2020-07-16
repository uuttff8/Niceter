//
//  SettingsButtonNodeCell.swift
//  Niceter
//
//  Created by uuttff8 on 3/31/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class SettingsButtonNodeCell: ASCellNode {
    struct Content {
        let title: String
    }
    
    enum State {
        case `default`
        case destructive
    }
    
    private let titleNode = ASTextNode()
    private let separatorNode = ASDisplayNode()
    
    private let content: SettingsButtonNodeCell.Content
    private let currentState: State
    // MARK: - Object life cycle
    
    init(with content: SettingsButtonNodeCell.Content, state: SettingsButtonNodeCell.State) {
        self.content = content
        self.currentState = state
        
        super.init()
        self.setupTitleNode()
        self.buildNodeHierarchy()
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title,
                                                           attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes: [NSAttributedString.Key: NSObject] {
        if currentState == .destructive {
            return [NSAttributedString.Key.foregroundColor: UIColor.systemRed,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        } else {
            return [NSAttributedString.Key.foregroundColor: UIColor.label,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        }
    }
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        [titleNode, separatorNode].forEach { (node) in
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
                titleNode
                    .flexShrink(1.0)
            }.padding(Edge.Set.all, 16.0)
        }
    }
}
