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
    
    // MARK: - Private Elements
    private lazy var viewModel = ShowRepliesViewModel(roomRecreates: self.roomRecreates, roomId: self.roomId)
    private let roomRecreates: [RoomRecreateSchema]
    private let roomId: String
    
    init(coordinator: ShowRepliesCoordinator, roomRecreates: [RoomRecreateSchema], roomId: String) {
        self.coordinator = coordinator
        self.roomRecreates = roomRecreates
        self.roomId = roomId
        
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
