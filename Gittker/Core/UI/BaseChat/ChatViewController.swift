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
    let userdata: MockUser = ShareData().userdata?.toMockUser() ?? MockUser(senderId: "", displayName: "")
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportMenuItem = UIMenuItem(title: "Report", action: #selector(MessageCollectionViewCell.report(_:)))
        UIMenuController.shared.menuItems = [reportMenuItem]

        self.view.backgroundColor = UIColor.systemBackground
        configureMessageCollectionView()
        configureMessageInputBarForDarkMode()
        configureBackroundMessageReading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFirstMessages()
        super.viewWillAppear(animated)
        subscribeOnMessagesEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // SHOULD BE IMPLEMENTED
    func subscribeOnMessagesEvent() { }
    
    func loadFirstMessages() { }
    
    func loadOlderMessages() {  }
    
    func sendMessage(tmpMessage: MockMessage) { }
    
    func joinButtonHandlder() { }
    
    func markMessagesAsRead(messagesId: [String]) { }
    
    func reportMessage(message: MockMessage) { }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: GittkerMessage) {
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
    
    func deleteMessage(by passedId: String) {        
        let index = messageList.firstIndex(where: { (mess) in
            passedId == mess.message.messageId
        })
                
        if let index = index {
            messageList.remove(at: index)
                        
            messagesCollectionView.performBatchUpdates({
                messagesCollectionView.deleteSections(IndexSet(integer: index))
//                messagesCollectionView.reloadSections([messageList.count - 2])
            }) { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    func updateMessage(_ newMessage: GittkerMessage) {
        let index = messageList.firstIndex(where: { (mess) in
            mess.message.messageId == newMessage.message.messageId
        })
        
        if let index = index {
            messageList[index].message = newMessage.message
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
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
        
        //        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
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
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let message = messageList[indexPath.section]
        switch action {
        case NSSelectorFromString("report:"):
            return isFromCurrentSender(message: message.message) ? false : true
        default:
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let message = messageList[indexPath.section]
        switch action {
        case NSSelectorFromString("report:"):
            reportMessage(message: message.message)
        default:
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
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

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
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
        print("Mention selected: \(mention)")
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
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
                self?.messageInputBar.inputTextView.placeholder = "Message"
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
                self.deleteMessage(by: tmpId)
            }
        }
        
        self.insertMessage(message)
    }
}

extension MessageCollectionViewCell {
    @objc func report(_ sender: Any?) {
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("report:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}
