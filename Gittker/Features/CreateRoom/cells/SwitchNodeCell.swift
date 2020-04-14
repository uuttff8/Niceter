//
//  SwitchDisclosureNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

final class SwitchNodeCell: ASCellNode {
    struct Content {
        let title: String
        let isSwitcherOn: Bool
        let isSwitcherActive: Bool
    }
    
    public var switchChanged: ((Bool) -> Void)?
    
    private let titleNode = ASTextNode()
    private let switchNode = ASDisplayNode { () -> UIView in
        let switcher = UISwitch()
        return switcher
    }
    
    private let content: SwitchNodeCell.Content
    
    // MARK: - Object life cycle
    init(with content: SwitchNodeCell.Content) {
        self.content = content
        
        super.init()
        self.setupTitleNode()
        self.buildNodeHierarchy()
        self.selectionStyle = .none
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content.title, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }()
    
    override func layout() {
        super.layout()
        let switcher = self.switchNode.view as? UISwitch
        switcher?.isOn = self.content.isSwitcherOn
        switcher?.isEnabled = self.content.isSwitcherActive
        switcher?.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
    }
    
    @objc private func switchAction(_ sender: UISwitch) {
        switchChanged?(sender.isOn)
    }
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [titleNode, switchNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        self.titleNode.style.flexShrink = 1
        
        let insetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 30.0, right: 56.0), child: switchNode)
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [self.titleNode, spacer, insetLayoutSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 14.0, left: 16.0, bottom: 14.0, right: 16.0), child: finalSpec)
    }
}
