//
//  SuggestedRoomsViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class SuggestedRoomsView: ASDisplayNode {
    private let titleNode = ASTextNode()
    
    override init() {
        super.init()
        setupNodes()
    }
    
    private func setupNodes() {
        setupTitleNode()
    }
    
    private func setupTitleNode() {
        titleNode.attributedText = NSAttributedString(string: "Horosho")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let subnode = ASDisplayNode { () -> UIView in
            let view = UIView()
            view.backgroundColor = UIColor.green
            view.frame.size = CGSize(width: 60, height: 100)
            return view
        }
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: subnode)
        return centerSpec
    }
}
