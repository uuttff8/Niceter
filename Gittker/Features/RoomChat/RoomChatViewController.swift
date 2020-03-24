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
    
    var viewModel = RoomChatViewModel()
    
    private var roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func loadFirstMessages() {
        viewModel.loadFirstMessages(roomId: roomId) { (gittMessages) in
            DispatchQueue.main.async {
                self.messageList = gittMessages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    override func subscribeOnLoadNewMessages() {
        FayeEventRoomBinder(roomId: roomId)
            .subscribe(
                onNew: { [weak self] (message: GittkerMessage) in
                    self?.insertMessage(message)
                }, onDeleted: { [weak self] (id) in
                    self?.deleteMessage(by: id)
                }, onUpdate: { [weak self] (message: GittkerMessage) in
                    self?.updateMessage(message)
                }
        )
    }
    
    override func loadOlderMessages() {
        
        viewModel.loadOlderMessages(messageId: messageList[0].message.messageId,
                                    roomId: roomId)
        { (gittMessages) in
            DispatchQueue.main.async {
                self.messageList.insert(contentsOf: gittMessages, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
    }
}
