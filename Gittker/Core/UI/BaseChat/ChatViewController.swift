//
//  ChatViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit
import SafariServices

class ConversationTemporaryMessageAdapter {
    static func generateChildMessageTmpId(userId: String, text: String) -> String {
        let textSubstring = text.prefix(64)
        return "tmp-\(userId)-\(textSubstring)"
    }
}

class ChatViewController: MessagesViewController {
    var messageList: [GittkerMessage] = []
    private var unreadMessagesIdStoring: [String] = []
    private var loadingdMessagesIdStoring: [String] = []
    
    // to read unread messages in backround
    private var timer = Timer()
    
    
    /// The `BasicAudioController` controll the AVAudioPlayer state (play, pause, stop) and udpate audio cell UI accordingly.
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    var canFetchMoreResults = true
    let userdata: MockUser = ShareData().userdata?.toMockUser() ?? MockUser(senderId: "", displayName: "", username: "")
    
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
    
    func configureMessageCollectionView() {
        guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
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
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        //        return NSAttributedString(string: "ASDASDASd")
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
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
            
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let message = messageList[indexPath.section].message
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            var actionList = [UIMenuElement]()
            
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { (_) in
                if case .text(let text) = message.kind {
                    UIPasteboard.general.string = text
                }
            }
            actionList.append(copyAction)
            
            if self.isFromCurrentSender(message: message) {
                
                                                            // 5 min
                if Date() < message.sentDate.addingTimeInterval(300) {
                    let editAction = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { _ in
                        self.editMessageUI(message: message)
                    }
                    actionList.append(editAction)
                }
                
                
                
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
                    self.deleteMessage(message: message)
                }
                actionList.append(deleteAction)
                
                return UIMenu(title: "", children: actionList)
            } else {
                let reportAction = UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.bubble")) { (_) in
                    self.reportMessage(message: message)
                }
                actionList.append(reportAction)
                
                return UIMenu(title: "", children: actionList)
            }
        }
        
        return config
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return userdata
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section].message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageList.count
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
}

// MARK: - Chat Insert, Delete, Update
extension ChatViewController {
    func insertMessageUI(_ message: GittkerMessage) {
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
    
    func updateMessageUI(_ newMessage: GittkerMessage) {
        let index = messageList.firstIndex(where: { (mess) in
            mess.message.messageId == newMessage.message.messageId
        })
        
        if let index = index {
            messageList[index].message = newMessage.message
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
    private func updateMessageUIAndAvoidMessageResend(tmpId: String, message: GittkerMessage) {
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
        let tmpMessId = ConversationTemporaryMessageAdapter.generateChildMessageTmpId(userId: userdata.senderId, text: text)
        let tmpMessage = MockMessage(text: text, user: userdata, messageId: tmpMessId, date: Date(), unread: false)
        let gittMess = GittkerMessage(message: tmpMessage, avatarUrl: nil, isLoading: true)
        
        addToMessageMap(message: gittMess, isFirstly: false)
        self.sendMessage(tmpMessage: tmpMessage)
    }
    
    func addToMessageMap(message: GittkerMessage, isFirstly: Bool) {
        if isFirstly {
            if case let MessageKind.text(text) = message.message.kind {
                let tmpId = ConversationTemporaryMessageAdapter.generateChildMessageTmpId(userId: userdata.senderId, text: text)
                
                self.updateMessageUIAndAvoidMessageResend(tmpId: tmpId, message: message)
                // if not return, new message will appear again
                return
            }
        }
        
        self.insertMessageUI(message)
    }
}
