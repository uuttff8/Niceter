//
//  ProfileAdditionalInfoNode.swift
//  Gittker
//
//  Created by uuttff8 on 3/31/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

public final class ProfileAdditionalInfoNode: ASCellNode {
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 20, height: 20)
    }()
    
    private let imageNode = ASImageNode()
    private let titleNode = ASTextNode()
    
    var infoTitle: String {
        didSet {
            setupNodes()
        }
    }
    // MARK: - Object life cycle
    
    init(with image: UIImage, title: String) {
        self.infoTitle = title
        self.imageNode.image = image
        super.init()
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    func updateCell(with title: String) {
        self.infoTitle = title
        setupNodes()
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
    }
    
    private func setupImageNode() {
        self.imageNode.style.preferredSize = self.imageSize
        self.imageNode.contentMode = .scaleAspectFit
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.infoTitle, attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.label]
    }()
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        [imageNode, titleNode].forEach { (node) in
            self.addSubnode(node)
        }
    }
    
    // MARK: - Layout
        
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [self.imageNode, self.titleNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0.0, right: 0.0), child: finalSpec)
    }
}