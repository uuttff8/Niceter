//
//  ChatViewController.swift
//  Niceter
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit
import SafariServices
import MarkdownKit

private class ConversationTemporaryMessageAdapter {
    static func generateChildMessageTmpId(userId: String, text: String) -> String {
        let textSubstring = text.prefix(64)
        return "tmp-\(userId)-\(textSubstring)"
    }
}

private class DefaultErrorData {
    static var defaultUser: MockUser {
        MockUser(senderId: "", displayName: "", username: "")
    }
}

class ChatViewController: MessagesViewController {
    var messageList: [NiceterMessage] = []
    private var unreadMessagesIdStoring: [String] = []
    private var loadingdMessagesIdStoring: [String] = []
    
    // to read unread messages in backround
    private var timer = Timer()
    
    var canFetchMoreResults = true
    let userdata: MockUser = ShareData().userdata?.toMockUser() ?? DefaultErrorData.defaultUser
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        loadFirstMessages()
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
        configureMessageCollectionView()
        configureMessageInputBarForDarkMode()
        configureBackroundMessageReading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeOnMessagesEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - SHOULD BE IMPLEMENTED
    func subscribeOnMessagesEvent() { }
    
    func loadFirstMessages() { }
    
    func loadOlderMessages() {  }
    
    func sendMessage(tmpMessage: MockMessage) { }
    
    func joinButtonHandlder() { }
    
    func markMessagesAsRead(messagesId: [String]) { }
    
    func reportMessage(message: MockMessage) { }
    
    func deleteMessage(message: MockMessage) { }
    
    func editMessage(message: MockMessage) { }
    
    // navigation
    func showProfileScreen(username: String) { }
    
    // for use in editing message extend
    func editMessageUI(message: MockMessage) { }
    
    func showReplies(messageId: String) {  }
    
    // MARK: - Helpers
    private func configureBackroundMessageReading() {
        // unread messages every 2 second
        self.timer = Timer.scheduledTimer(timeInterval: 2,
                                          target: self,
                                          selector: #selector(self.readMessagesInBackround),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc
    private func readMessagesInBackround() {
        DispatchQueue.global(qos: .background).async {
            if self.unreadMessagesIdStoring.count > 0 {
                self.markMessagesAsRead(messagesId: self.unreadMessagesIdStoring)
                // after reading messages delete all messages that are unread
                self.unreadMessagesIdStoring.removeAll()
            }
        }
    }
    
    private func configureMessageInputBarForDarkMode() {
        messageInputBar.inputTextView.textColor = .label
        messageInputBar.inputTextView.placeholderLabel.textColor = .secondaryLabel
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.placeholderLabel.text = "Message".localized()
    }
    
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isMessageHasReplies(at indexPath: IndexPath) -> Bool {
        guard indexPath.section < messageList.count else { return false }
        let message = messageList[indexPath.section].message
        return (message.threadMessageCount != nil && (message.threadMessageCount ?? 0) > 0) ? true : false
    }
    
    func configureMessageCollectionView() {
        guard let flowLayout =
            messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
                return
        }
        flowLayout.collectionView?.backgroundColor = .systemBackground
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.setImage(UIImage(named: "right-arrow"), for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.systemBackground.withAlphaComponent(0.3),
            for: .highlighted
        )
        messageInputBar.setRightStackViewWidthConstant(to: 34, animated: false)
    }
    
    func messageTopLabelAttributedText(for message: MessageType,
                                       at indexPath: IndexPath
    ) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        )
    }
    
    func messageBottomLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath
    ) -> NSAttributedString? {
        let dateString = dateFormatter.string(from: message.sentDate)
        let message = messageList[indexPath.section].message
        
        if let threadMessageCount = message.threadMessageCount, threadMessageCount > 0 {
            print(threadMessageCount)
            return NSAttributedString(
                string: "\(dateString), \(threadMessageCount) replies",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
            )
        }
        
        return NSAttributedString(
            string: dateString,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
        )
    }
    
    private func openUrlInsideApp(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // count unreaded messages
        for _ in messagesCollectionView.visibleCells {
            if messageList[indexPath.section].message.unread {
                unreadMessagesIdStoring.append(messageList[indexPath.section].message.messageId)
            }
        }
        
        // load older messages at top
        if indexPath.section == 20 {
            if canFetchMoreResults {
                self.loadOlderMessages()
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            var actionList = [UIMenuElement]()
            let message = self.messageList[indexPath.section].message
            
            let copyAction = UIAction(title: "Copy".localized(), image: UIImage(systemName: "doc.on.doc")) { (_) in
                if case MessageKind.attributedText(let text) = message.kind {
                    UIPasteboard.general.string = text.string
                }
            }
            
            if self.isMessageHasReplies(at: indexPath) {
                let seeRepliesAction = UIAction(title: "Show \(message.threadMessageCount!) replies",
                                                image: UIImage(systemName: "rectangle.expand.vertical"))
                { (_) in
                    self.showReplies(messageId: message.messageId)
                }
                
                actionList.append(seeRepliesAction)
            }
            
            actionList.append(copyAction)
            
            if self.isFromCurrentSender(message: message) {
                return self.createCtxMenuForCurrentSender(message: message, default: &actionList)
            } else {
                return self.createCtxMenuForAnotherSender(message: message, default: &actionList)
            }
        }
        
        return config
    }
    
    private func createCtxMenuForCurrentSender(
        message: MockMessage,
        default actionList: inout [UIMenuElement]
    ) -> UIMenu {
        // 5 min
        if Date() < message.sentDate.addingTimeInterval(300) {
            let editAction = UIAction(title: "Edit".localized(),
                                      image: UIImage(systemName: "square.and.pencil")) { _ in
                                        self.editMessageUI(message: message)
            }
            actionList.append(editAction)
        }
        
        let deleteAction = UIAction(title: "Delete".localized(),
                                    image: UIImage(systemName: "trash")) { _ in
                                        self.deleteMessage(message: message)
        }
        actionList.append(deleteAction)
        
        return UIMenu(title: "", children: actionList)
    }
    
    private func createCtxMenuForAnotherSender(
        message: MockMessage,
        default actionList: inout [UIMenuElement]
    ) -> UIMenu {
        let reportAction = UIAction(title: "Report".localized(),
                                    image: UIImage(systemName: "exclamationmark.bubble")) { (_) in
                                        self.reportMessage(message: message)
        }
        actionList.append(reportAction)
        
        return UIMenu(title: "", children: actionList)
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return userdata
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageType {
        return messageList[indexPath.section].message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageList.count
    }
}

// MARK: - Chat Insert, Delete, Update
extension ChatViewController {
    func insertMessageUI(_ message: NiceterMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func deleteMessageUI(by passedId: String) {
        let index = messageList.firstIndex(where: { (mess) in
            passedId == mess.message.messageId
        })
        
        if let index = index {
            messageList.remove(at: index)
            
            messagesCollectionView.performBatchUpdates({
                messagesCollectionView.deleteSections(IndexSet(integer: index))
            }) { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
        }
    }
    
    func updateMessageUI(_ newMessage: NiceterMessage) {
        let index = messageList.firstIndex(where: { (mess) in
            mess.message.messageId == newMessage.message.messageId
        })
        
        if let index = index {
            messageList[index].message = newMessage.message
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
    private func updateMessageUIAndAvoidMessageResend(tmpId: String, message: NiceterMessage) {
        let index = messageList.firstIndex(where: { (mess) in
            tmpId == mess.message.messageId
        })
        
        if let index = index {
            messageList[index].message = message.message
            messagesCollectionView.reloadDataAndKeepOffset()
        } else {
            self.insertMessageUI(message)
        }
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messageList[indexPath.section]
        
        showProfileScreen(username: message.message.user.username)
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        
        // Logic for URL Selected: https://files.gitter.im/gitterHQ/api/9TNg/thumb/Screen-Shot-2020-04-26-at-5.49.34-PM.png)%5D(https://files.gitter.im/gitterHQ/api/9TNg/Screen-Shot-2020-04-26-at-5.49.34-PM.png

        var url = url
        var screenStr = url.absoluteString
        while screenStr.contains(")%5D(") {
            screenStr = String(screenStr.dropFirst())
        }
        
        if screenStr.contains("%5D(") {
            screenStr = String(screenStr.dropFirst(4))
            url = URL(string: screenStr)!
        }
        
        openUrlInsideApp(url: url)
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        showProfileScreen(username: mention.replacingOccurrences(of: "@", with: ""))
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    @objc func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in }
        
        let components = inputBar.inputTextView.text
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            //                        sleep(2)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.inputTextView.placeholder = "Message".localized()
                self?.insertMessages(components!)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ text: String) {
        let mdParser = GitterMarkdown()
        
        let tmpMessId = ConversationTemporaryMessageAdapter.generateChildMessageTmpId(userId: userdata.senderId, text: text)
        let tmpMessage = MockMessage(attributedText: mdParser.parse(text),
                                     user: userdata,
                                     messageId: tmpMessId,
                                     date: Date(),
                                     originalText: text,
                                     unread: false,
                                     threadMessageCount: nil)
        let gittMess = NiceterMessage(message: tmpMessage, avatarUrl: nil, isLoading: true)
        
        addToMessageMap(message: gittMess, isFirstly: false)
        self.sendMessage(tmpMessage: tmpMessage)
    }
    
    func addToMessageMap(message: NiceterMessage, isFirstly: Bool) {
        if isFirstly {
            let tmpId = ConversationTemporaryMessageAdapter.generateChildMessageTmpId(userId: userdata.senderId,
                                                                                      text: message.message.originalText)
            
            self.updateMessageUIAndAvoidMessageResend(tmpId: tmpId, message: message)
            // if not return, new message will appear again
            return
        }
        
        self.insertMessageUI(message)
    }
}
