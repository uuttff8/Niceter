//
//  UserChatViewController.swift
//  Niceter
//
//  Created by uuttff8 on 4/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import MessageKit

final class UserChatViewController: RoomChatEditingMessageExtend {
    weak var coordinator: UserChatCoordinator?
    
    // MARK: - Private Elements
    private lazy var viewModel = ChatsViewModel(roomSchema: intermediate)
    private var fayeClient: FayeEventMessagesBinder?
    
    private var isJoined: Bool
    private var intermediate: UserRoomIntermediate
    
        
    // MARK: - Init
    init(coordinator: UserChatCoordinator, intermediate: UserRoomIntermediate, isJoined: Bool) {
        self.coordinator = coordinator
        self.intermediate = intermediate
        self.isJoined = isJoined
        print(isJoined)
        if !isJoined {
            self.fayeClient = nil
        } else {
            self.fayeClient = FayeEventMessagesBinder(roomId: intermediate.id) // if !isJoined then it will be wrong
        }
        
        super.init(rightBarImage: intermediate.avatarUrl ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Faye
    override func subscribeOnMessagesEvent() {
        if !isJoined {
            return
        } else {
            guard let fayeClient = fayeClient else { return }
            fayeClient
                .subscribe(
                    onNew: { [weak self] (message: NiceterMessage) in
                        self?.viewModel.addNewMessageToCache(message: message)
                        self?.addToMessageMap(message: message, isFirstly: true)
                    }, onDeleted: { [weak self] (id) in
                        self?.deleteMessageUI(by: id)
                    }, onUpdate: { [weak self] (message: NiceterMessage) in
                        self?.updateMessageUI(message)
                    }
            )
        }
    }

    //MARK: - Message actions
    override func loadFirstMessages() {
        if !isJoined {
            return
        } else {
            viewModel.loadFirstMessages() { (gittMessages) in
                DispatchQueue.main.async { [weak self] in
                    self?.messageList = gittMessages
                    self?.messagesCollectionView.reloadData()
                    self?.configureScrollAndPaginate()
                }
            }
        }
    }
        
    override func loadOlderMessages() {
        self.canFetchMoreResults = false
        
        if let firstMessageId = messageList.first?.message.messageId {
            viewModel.loadOlderMessages(messageId: firstMessageId)
            { (gittMessages: [NiceterMessage]) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.messageList.insert(contentsOf: gittMessages, at: 0)
                    self.insertSectionsAndKeepOffset(gittMessages: gittMessages)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.canFetchMoreResults = true
                    }
                }
            }
        }
    }
    
    override func deleteMessage(message: MockMessage) {
        self.viewModel.deleteMessage(messageId: message.messageId) { () in }
    }
    
    override func sendMessage(tmpMessage: MockMessage) {
        if case let MessageKind.attributedText(text) = tmpMessage.kind {
            
            viewModel.sendMessage(text: text.string) { (result) in
                switch result {
                case .success(_):
                    print("All is ok")
                case .failure:
                    print("All is bad")
                }
            }
        }
    }
    
        override func editMessage(message: MockMessage) {
            guard case MessageKind.attributedText(let messageText) = message.kind else { return }
            self.viewModel.editMessage(text: messageText.string, messageId: message.messageId) { (roomRecrSchema) in
                DispatchQueue.main.async {
                    self.editingMessage(self.editingMessagePlugin, shouldBecomeVisible: false)
                }
            }
        }
    
    override func showReplies(messageId: String) {
        self.viewModel.loadMessageThread(messageId: messageId) { (roomRecr) in
            self.coordinator?.showReplies(roomRecreates: roomRecr, roomId: self.intermediate.id)
        }
    }
    
    override func joinButtonHandlder() {        
        viewModel.joinToUserChat(userId: userdata.senderId, roomId: intermediate.id) { (roomSchema) in
            self.fayeClient = FayeEventMessagesBinder(roomId: roomSchema.id)
            self.isJoined = true
            self.intermediate.id = roomSchema.id
            self.viewModel.roomSchema.id = roomSchema.id
            self.loadFirstMessages()
            self.subscribeOnMessagesEvent()
            
            self.configureMessageInputBarForChat()
        }
    }
    
    override func markMessagesAsRead(messagesId: [String]) {
        self.viewModel.markMessagesAsRead(userId: userdata.senderId, messagesId: messagesId, completion: nil)
    }
    
    override func reportMessage(message: MockMessage) {
        self.viewModel.reportMessage(messageId: message.messageId) { (reportMessageSchema) in
            super.showOkAlert(config: SystemAlertConfiguration(title:
                "Thank You!\n\nYour report will be reviewed by Gitter team very soon.".localized(),
                                                               subtitle: nil))
        }
    }
    
    //MARK: - Navigation
    override func showProfileScreen(username: String) {
        coordinator?.showProfileScreen(username: username)
    }
    
    override func onAvatarTapped() {
        coordinator?.showProfileScreen(username: intermediate.uri!)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = intermediate.name
        
        if !isJoined {
            showJoinButton()
        } else {
            super.configureMessageInputBarForChat()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let fayeClient = fayeClient else { return }
        fayeClient.cancel()
    }
    
    #warning("refactor")
    private func configureScrollAndPaginate() {
        // scroll to unread message
        // note: unread limit is 100
//        if let indexPath = self.viewModel.findFirstUnreadMessage() {
//            // paginate if scrolls at top
//            if indexPath.section <= 20 {
//                self.loadOlderMessages()
//                if cached == 0 {
//                    self.messagesCollectionView.reloadSections(IndexSet(integer: 100))
//                }
//            }
//            self.messagesCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
//
//        } else {
            self.messagesCollectionView.scrollToBottom()
//        }
    }
    
}
