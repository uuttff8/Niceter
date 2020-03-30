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
    private lazy var viewModel = RoomChatViewModel(roomId: roomId)
    
    private var isJoined: Bool
    private var roomId: String
    
    init(coordinator: RoomChatCoordinator, roomId: String, isJoined: Bool) {
        self.coordinator = coordinator
        self.roomId = roomId
        self.isJoined = isJoined
        super.init(nibName: nil, bundle: nil)
        
        print(isJoined)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func loadFirstMessages() {
        viewModel.loadFirstMessages() { (gittMessages) in
            DispatchQueue.main.async { [weak self] in
                self?.messageList = gittMessages
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    override func subscribeOnMessagesEvent() {
        FayeEventMessagesBinder(roomId: roomId)
            .subscribe(
                onNew: { [weak self] (message: GittkerMessage) in
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
        { (gittMessages) in
            DispatchQueue.main.async { [weak self] in
                self?.messageList.insert(contentsOf: gittMessages, at: 0)
                self?.messagesCollectionView.reloadDataAndKeepOffset()
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
        print(true)
        configureMessageInputBarForChat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isJoined {
            showJoinButton()
        }
    }
    
    // Mark all messages as read
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.markMessagesAsRead(userId: userdata!.senderId, completion: nil)
    }
}
