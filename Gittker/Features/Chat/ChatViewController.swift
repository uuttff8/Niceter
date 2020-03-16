//
//  ChatViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController, Storyboarded {

    open var roomId: String?
    
    weak var coordinator: ChatCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(roomId)
    }
}
//
//extension ChatViewController: MessagesDataSource {
//    func currentSender() -> SenderType {
//        <#code#>
//    }
//    
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        <#code#>
//    }
//    
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        <#code#>
//    }
//    
//     
//}
