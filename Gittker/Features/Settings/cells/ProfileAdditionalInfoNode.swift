//
//  ProfileAdditionalInfoNode.swift
//  Gittker
//
//  Created by uuttff8 on 3/31/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

public final class ProfileAdditionalInfoNode: ASDisplayNode {
    private let titleNode = ASTextNode()
    private let imageNode = ASImageNode()
    
    public var image: UIImage
    public var title: String?
    
    init(image: UIImage) {
        self.image = image
        super.init()
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
    }
    
    private func setupTitleNode() {
        
    }
    
    private func setupImageNode() {
        
    }
    
    private func buildNodeHierarchy() {
        [titleNode, imageNode].forEach { (node) in
            self.addSubnode(node)
        }
    }

}
