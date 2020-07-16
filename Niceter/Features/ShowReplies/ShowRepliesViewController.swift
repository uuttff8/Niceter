//
//  ShowRepliesViewController.swift
//  Niceter
//
//  Created by uuttff8 on 7/16/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import MessageKit

final class ShowRepliesViewController: RoomChatBaseViewController {
    weak var coordinator: ShowRepliesCoordinator?
    
    private var roomRecreates: [RoomRecreateSchema]
    
    init(coordinator: ShowRepliesCoordinator, roomRecreates: [RoomRecreateSchema]) {
        self.coordinator = coordinator
        self.roomRecreates = roomRecreates
        
        super.init(rightBarImage: "")
    }
    
    override func loadFirstMessages() {
        self.messageList = roomRecreates.toNiceterMessages(isLoading: false)
        self.messagesCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
