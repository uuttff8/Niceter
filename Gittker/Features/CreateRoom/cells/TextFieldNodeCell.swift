//
//  TextFieldNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class TextFieldNodeCell: ASCellNode {
    struct Content {
        var defaultText: String?
    }
    
    let textFieldNode = ASEditableTextNode()
    private let content: TextFieldNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: TextFieldNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupSwitchNode()
        self.buildNodeHierarchy()
        self.selectionStyle = .none
    }
    
    // Internal Setup
    private func setupSwitchNode() {
        textFieldNode.attributedPlaceholderText = NSAttributedString(string: "Enter room name", attributes: textFieldPlaceholderAttributes)
        textFieldNode.typingAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.label,
                                          NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: 16)]
        if let text = content.defaultText {
            textFieldNode.attributedText = NSAttributedString(string: text, attributes: textFieldTextAttributes)
        }
        textFieldNode.maximumLinesToDisplay = 1
    }
    
    private var textFieldTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    private var textFieldPlaceholderAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [textFieldNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        textFieldNode.style.flexGrow = 1
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0), child: textFieldNode)
    }
}
