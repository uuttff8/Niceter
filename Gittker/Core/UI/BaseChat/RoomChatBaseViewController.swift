//
//  RoomChatViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit
import Nuke

private struct Constants {
    static let messageCornerRadius: CGFloat = 5.0
}

class RoomChatBaseViewController: ChatViewController {
    private let myBtnView: UIButton = UIButton(type: .custom)
    private let rightBarImage: String
    
    lazy var joinChatButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .primaryColor
        button.setTitle("join", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        button.addTarget(self, action: #selector(joinChat), for: .touchUpInside)
        return button
    }()
    
    var rightImageBarButton: UIBarButtonItem
    
    init(rightBarImage: String) {
        self.rightBarImage = rightBarImage
        rightImageBarButton = UIBarButtonItem()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showJoinButton() {
        configureMessageInputBarWithJoinButton()
    }
    
    @objc
    func joinChat() {
        joinButtonHandlder()
    }
    
    @objc
    func onAvatarTapped() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRightBarButton()
    }
    
    private func setupRightBarButton() {
        let button = UIButton(type: .custom)
        
        let request = ImageRequest(url: URL(string: rightBarImage)!, processors: [
            ImageProcessor.Circle()
        ])
        
        ImagePipeline.shared.loadImage(with: request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    button.setImage(response.image, for: .normal)
                    button.imageView?.contentMode = .scaleAspectFit
                }
            default: break
            }
        }
        
        button.addTarget(self, action: #selector(onAvatarTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 45, height: 45)

        rightImageBarButton.customView = button
        self.navigationItem.rightBarButtonItem = rightImageBarButton
    }
    
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        layout?.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        additionalBottomInset = 30
    }
    
    func configureMessageInputBarWithJoinButton() {
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 4
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.setMiddleContentView(joinChatButton, animated: false)
    }

    
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].message.user == messageList[indexPath.section - 1].message.user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].message.user == messageList[indexPath.section + 1].message.user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    func configureMessageInputBarForChat() {
        super.configureMessageInputBar()
        messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        messageInputBar.sendButton
            .onSelected { item in
                item.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }.onDeselected { item in
            item.transform = .identity
        }
    }
    
    override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    func insertSectionsAndKeepOffset(gittMessages: [GittkerMessage]) {
        CATransaction.disableAnimations {
            // stop scrolling
            messagesCollectionView.setContentOffset(messagesCollectionView.contentOffset, animated: false)
            // calculate the offset and reloadData
            let beforeContentSize = messagesCollectionView.contentSize
            
            self.messagesCollectionView.performBatchUpdates({
                let array = Array(0..<gittMessages.count)
                self.messagesCollectionView.insertSections(IndexSet(array))
            }, completion: { _ in
                self.messagesCollectionView.layoutIfNeeded()
                let afterContentSize = self.messagesCollectionView.contentSize
                
                // reset the contentOffset after data is updated
                let newOffset = CGPoint(
                    x: self.messagesCollectionView.contentOffset.x + (afterContentSize.width - beforeContentSize.width),
                    y: self.messagesCollectionView.contentOffset.y + (afterContentSize.height - beforeContentSize.height))
                self.messagesCollectionView.setContentOffset(newOffset, animated: false)
            })

        }
    }
}


// MARK: - MessagesDisplayDelegate

extension RoomChatBaseViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return [.foregroundColor: UIColor.secondaryLabel]
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .secondarySystemBackground
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { (messageView) in
            if self.isFromCurrentSender(message: message) {
                messageView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: Constants.messageCornerRadius)
            } else {
                messageView.roundCorners(corners: [.topLeft, .topRight, .bottomRight], radius: Constants.messageCornerRadius)
            }
        }
        
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // nil when message from yourself
        guard let avatarUrl = messageList[indexPath.section].avatarUrl else { return }
                
        // Safety: Gitter backend always returns avatar from github which is always available
        // Nuke loads images asyncrohonous 
        Nuke.loadImage(with: URL(string: avatarUrl)!, into: avatarView)
    }
}

// MARK: - MessagesLayoutDelegate

extension RoomChatBaseViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath)) ? 16 : 0
    }
}

extension UIViewController {
    func showOkAlert(config: SystemAlertConfiguration) {
        let alert = UIAlertController(title: config.title, message: config.subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        let topViewController = UIApplication.shared.windows.last!.rootViewController!
        topViewController.present(alert, animated: true)
    }
}
