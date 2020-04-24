//
//  RoomTableNode.swift
//  Gittker
//
//  Created by uuttff8 on 3/21/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit
import TextureSwiftSupport

class RoomTableNode: ASCellNode {
    
    struct Content {
        let avatarUrl: String
        let title: String
        let subtitle: String
        let unreadItems: Int
    }
    
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 64, height: 64)
    }()
    
    private let room: RoomTableNode.Content
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    private let unreadNodeText = ASTextNode()
    private let unreadNode = ASDisplayNode()
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with room: RoomTableNode.Content) {
        self.room = room
        
        super.init()
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
        setupSubtitleNode()
        setupUnread()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: room.avatarUrl)
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRoundingType = .precomposited
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.room.title, attributes: self.titleTextAttributes())
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
    }
    
    private func setupSubtitleNode() {
        self.subtitleNode.attributedText = NSAttributedString(string: self.room.subtitle, attributes: self.subtitleTextAttributes())
        self.subtitleNode.maximumNumberOfLines = 2
        self.subtitleNode.truncationMode = .byTruncatingTail
    }
    
    private func setupUnread() {
        if room.unreadItems > 0 {
            self.unreadNodeText.attributedText = NSAttributedString(string: String(self.room.unreadItems), attributes: [.foregroundColor: UIColor.label])
            self.unreadNode.cornerRadius = 10
            self.unreadNode.backgroundColor = UIColor.tertiarySystemFill
        }
    }
    
    private var subtitleTextAttributes = {
        return [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
    }
    
    // MARK: - Build node hierarchy
    
    private func buildNodeHierarchy() {
        [imageNode, titleNode, subtitleNode, separatorNode].forEach { (node) in
            self.addSubnode(node)
        }
        
        if room.unreadItems > 0 {
            [unreadNode, unreadNodeText].forEach { (node) in
                self.addSubnode(node)
            }
        }
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0, y: 0.0, width: self.calculatedSize.width, height: separatorHeight)
        self.separatorNode.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            HStackLayout(spacing: 10.0) {
                imageNode
                VStackLayout(spacing: 2.0) {
                    titleNode
                    subtitleNode
                }
                .flexShrink(1.0)
                
                if room.unreadItems > 0 {
                    ASLayoutSpec().flexGrow(1)
                    
                    VStackLayout(spacing: 5.0, justifyContent: .center, alignItems: .center) {
                        OverlayLayout(content: {
                            unreadNode
                                .preferredSize(CGSize(width: 40, height: 30))
                        }) {
                            CenterLayout(centeringOptions: .XY, sizingOptions: .minimumXY) {
                                unreadNodeText
                            }
                        }
                    }
                }
            }.padding(UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 16.0))
        }
    }
}
