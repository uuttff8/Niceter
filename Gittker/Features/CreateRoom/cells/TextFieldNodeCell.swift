//
//  TextFieldNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class TextFieldNodeCell: ASCellNode {
    /// if height is nil, then it is 1 line textfield
    struct Content {
        let placeholder: String?
        let defaultText: String?
        let height: CGFloat?
    }
    
    let textFieldNode = ASEditableTextNode()
    private let content: TextFieldNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: TextFieldNodeCell.Content, delegate: ASEditableTextNodeDelegate) {
        self.content = content
        
        super.init()
        self.setupTextFieldNode()
        self.buildNodeHierarchy()
        self.selectionStyle = .none
        self.textFieldNode.delegate = delegate
    }
    
    // Internal Setup
    private func setupTextFieldNode() {
        // placeholder
        if let placeholder = content.placeholder {
            textFieldNode.attributedPlaceholderText = NSAttributedString(string: placeholder,
                                                                         attributes: textFieldPlaceholderAttributes)
        }
        
        // default text
        if let text = content.defaultText {
            textFieldNode.attributedText = NSAttributedString(string: text,
                                                              attributes: textFieldTextAttributes)
        }
        
        // when typing
        textFieldNode.typingAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.label,
                                          NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: 16)]
        
        if let height = content.height {
            textFieldNode.style.preferredSize.height = height
        } else {
            textFieldNode.maximumLinesToDisplay = 1
        }
    }
    
    private var textFieldTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    private var textFieldPlaceholderAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [textFieldNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            InsetLayout(insets: UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0)) {
                textFieldNode
                    .flexGrow(1)
            }
        }
    }
}
