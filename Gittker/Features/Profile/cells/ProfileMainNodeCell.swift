//
//  SettingsProfileNodeCell.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class ProfileMainNodeCell: ASCellNode {
    // MARK: - Variables
    
    private lazy var imageSize: CGSize = {
        return CGSize(width: 50, height: 50)
    }()
    
    private var content: UserSchema?
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    private let gitInfoNode = ASTextNode()
    
    private lazy var locationNode = ProfileAdditionalInfoNode(
        with: Config.Images.profileLocation,
        title: self.content?.location ?? ""
    )
    private lazy var emailNode = ProfileAdditionalInfoNode(
        with: Config.Images.profileEnvelope,
        title: self.content?.email ?? ""
    )
    private lazy var linkNode = ProfileAdditionalInfoNode(
        with: Config.Images.profileLink,
        title: self.content?.website ?? ""
    )
    private lazy var companyNode = ProfileAdditionalInfoNode(
        with: Config.Images.profileCompany,
        title: self.content?.company ?? ""
    )
    
    private let separatorNode = ASDisplayNode()
    
    // MARK: - Object life cycle
    
    init(with content: UserSchema?) {
        self.content = content
        
        super.init()
        selectionStyle = .none
        
        self.setupNodes()
        self.buildNodeHierarchy()
    }
    
    func configureCell(with content: UserSchema) {
        self.content = content
        setupNodes()
    }
    
    override func asyncTraitCollectionDidChange() {
        locationNode.imageNode.image = Config.Images.profileLocation
        emailNode.imageNode.image = Config.Images.profileEnvelope
        linkNode.imageNode.image = Config.Images.profileLink
        companyNode.imageNode.image = Config.Images.profileCompany
    }
    
    // MARK: - Setup nodes
    
    private func setupNodes() {
        setupImageNode()
        setupTitleNode()
        setupSubtitle()
        setupGitInfoTitle()
        setupAdditionalInfo()
    }
    
    private func setupImageNode() {
        self.imageNode.url = URL(string: self.content?.getGitterImage() ?? "")
        self.imageNode.style.preferredSize = self.imageSize
        
        self.imageNode.cornerRadius = self.imageSize.width / 2
        self.imageNode.clipsToBounds = true
    }
    
    private func setupTitleNode() {
        self.titleNode.attributedText = NSAttributedString(string: self.content?.displayName ?? "", attributes: self.titleTextAttributes)
        self.titleNode.maximumNumberOfLines = 1
        self.titleNode.truncationMode = .byTruncatingTail
    }
    
    private var titleTextAttributes = {
        return [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.label]
    }()
    
    private func setupSubtitle() {
        self.subtitleNode.attributedText = NSAttributedString(string: self.content?.username ?? "", attributes: self.subtitleTextAttributes)
        self.subtitleNode.maximumNumberOfLines = 1
        self.subtitleNode.truncationMode = .byTruncatingTail
    }
    
    private var subtitleTextAttributes = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.label]
    }()

    
    private func setupGitInfoTitle() {
        self.gitInfoNode.attributedText = NSAttributedString(string:
            "\(content?.github?.followers ?? 0) followers"
                + " \(content?.github?.following ?? 0) following"
                + " \(self.content?.github?.public_repos ?? 0) public repos",
            attributes: gitInfoAttrubuttes)
    }
    
    private var gitInfoAttrubuttes = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.label]
    }()
    
    private func setupAdditionalInfo() {
        self.locationNode.infoTitle = self.content?.location ?? "Not specified"
        self.emailNode.infoTitle = self.content?.email ?? "Not specified"
        self.linkNode.infoTitle = self.content?.website ?? "Not Specified"
        self.companyNode.infoTitle = self.content?.company ?? "Not Specified"
    }
    
    // MARK: - Build node hierarchy
    private func buildNodeHierarchy() {
        [imageNode, titleNode, separatorNode, subtitleNode, gitInfoNode,].forEach { (node) in
            self.addSubnode(node)
        }
        
        #warning("Delete nodes if values is nil")
//        if let _ = self.content?.location {
            self.addSubnode(locationNode)
//        }
        
//        if let _ = self.content?.email {
            self.addSubnode(emailNode)
//        }
        
//        if let _ = self.content?.website {
            self.addSubnode(linkNode)
//        }
        
//        if let _ = self.content?.company {
            self.addSubnode(companyNode)
//        }
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        let separatorHeight = 1 / UIScreen.main.scale
        self.separatorNode.frame = CGRect(x: 0.0, y: 0.0, width: self.calculatedSize.width, height: separatorHeight)
        self.separatorNode.backgroundColor = UIColor.separator
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        
        let infoSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: 5,
                                         justifyContent: .start,
                                         alignItems: .start,
                                         children:
            [self.titleNode, self.subtitleNode, self.gitInfoNode, self.locationNode, self.emailNode, linkNode, companyNode]
        )
        
        let finalSpec = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 10.0,
                                          justifyContent: .start,
                                          alignItems: .start,
                                          children: [self.imageNode, infoSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0), child: finalSpec)
    }
}
