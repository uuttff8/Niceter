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

final class RoomChatViewController: ChatViewController, Storyboarded {
    weak var coordinator: RoomChatCoordinator?
    public var roomId: String?
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            FayeEventRoomBinder(roomId: self.roomId!)
                .loadMessages { (messages: [MockMessage], avatars: [Avatar]) in
                    DispatchQueue.main.async {
                        self.messageList = messages
                        self.avatarList = avatars
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
            }
        }
        
    }
    
    override func subscribeOnLoadNewMessages() {
        FayeEventRoomBinder(roomId: roomId!)
            .onNewMessage { [weak self] (message) in
                self?.insertMessage(message)
        }
        
    }
}

// MARK: - MessagesDisplayDelegate

extension RoomChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .label : .label
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.primaryColor : UIColor.darkGray
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = avatarList[indexPath.section]
        avatarView.set(avatar: avatar)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }
    
}

// MARK: - MessagesLayoutDelegate

extension RoomChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}
