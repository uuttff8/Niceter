//
//  ChatViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit
import MapKit

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}

final class RoomChatViewController: RoomChatBaseViewController {
    weak var coordinator: RoomChatCoordinator?
    private lazy var viewModel = RoomChatViewModel(roomSchema: roomSchema)
    
    private var isJoined: Bool
    private var roomSchema: RoomSchema
    
    private var cached = 2
    
    init(coordinator: RoomChatCoordinator, roomSchema: RoomSchema, isJoined: Bool) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.isJoined = isJoined
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureScrollAndPaginate() {
        // scroll to unread message
        // note: unread limit is 100
        if let indexPath = self.viewModel.findFirstUnreadMessage() {
            // paginate if scrolls at top
            if indexPath.section <= 20 {
                self.loadOlderMessages()
                
                if cached == 0 {
                    self.messagesCollectionView.reloadSections(IndexSet(integer: 100))
                }
            }
            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            
        } else {
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    override func loadFirstMessages() {
        viewModel.loadFirstMessages() { (gittMessages) in
            DispatchQueue.main.async { [weak self] in
                self?.messageList = gittMessages
                if self!.cached > 0 {
                    self?.messagesCollectionView.reloadData()
                    self!.cached - 1
                }
                
                self?.configureScrollAndPaginate()
            }
        }
    }
    
    override func subscribeOnMessagesEvent() {
        FayeEventMessagesBinder(roomId: roomSchema.id)
            .subscribe(
                onNew: { [weak self] (message: GittkerMessage) in
                    // if got message from yourself, do nothing, we handle this message by yourself to provide offline messages
                    if message.message.sender.senderId == self?.userdata?.senderId {
                        return
                    }
                    
                    self?.insertMessage(message)
                }, onDeleted: { [weak self] (id) in
                    self?.deleteMessage(by: id)
                }, onUpdate: { [weak self] (message: GittkerMessage) in
                    self?.updateMessage(message)
                }
        )
    }
    
    override func loadOlderMessages() {
        viewModel.loadOlderMessages(messageId: messageList[0].message.messageId)
        { (gittMessages: [GittkerMessage]) in
            DispatchQueue.main.async { [weak self] in
                self?.messageList.insert(contentsOf: gittMessages, at: 0)
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.canFetchMoreResults = true
                }
            }
        }
    }
    
    override func sendMessage(inputBar: MessageInputBar, text: String) {
        viewModel.sendMessage(text: text) { (result) in
            switch result {
            case .success(_):
                print("All is ok")
            case .failure(_):
                print("All is bad")
            }
        }
    }
    
    override func joinButtonHandlder() {
        viewModel.joinToChat(userId: userdata!.senderId, roomId: roomSchema.id) { (success) in
            self.configureMessageInputBarForChat()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isJoined {
            showJoinButton()
        } else {
            configureMessageInputBarForChat()
        }
    }
}
