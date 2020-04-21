//
//  RoomInfoViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoViewModel: NSObject {
    var updateTableNode: ((_ newList: [UserSchema]) -> Void)? = nil
    
    weak var coordinator: RoomInfoCoordinator?
    
    let roomSchema: RoomSchema
    var roomSchemaPeople = [UserSchema]()
    
    init(coordinator: RoomInfoCoordinator, roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.roomSchemaPeople = prefetchedUsers
        super.init()
    }
    
    func loadMorePeople() {
        GitterApi.shared.listUsersInRoom(roomId: roomSchema.id, skip: roomSchemaPeople.count) { userSchemaList in
            self.roomSchemaPeople.insert(contentsOf: userSchemaList, at: self.roomSchemaPeople.count - 1)
            self.updateTableNode?(userSchemaList)
        }
    }
}


extension RoomInfoViewModel: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return RoomInfoSection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch RoomInfoSection.allCases[section] {
        case .peopleIn: return self.roomSchemaPeople.count
        default: return 1
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            switch RoomInfoSection.allCases[indexPath.section] {
            case .generalInfo:
                return RoomInfoGeneralInfoNode(with: self.roomSchema)
            case .topicDescription:
                guard let topic = self.roomSchema.topic, !topic.isEmpty else {
                    return ASCellNode()
                }
                
                return RoomInfoTopicNode(with: topic)
            case .peopleIn:
                let user = self.roomSchemaPeople[indexPath.row]
                return RoomInfoUserInNode(with: RoomInfoUserInNode.Content(title: user.displayName ?? "",
                                                                           image: user.avatarURLSmall ?? ""))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch RoomInfoSection.allCases[indexPath.section] {
        case .peopleIn:
            let user = self.roomSchemaPeople[indexPath.row]
            
            // dont select row if user is logined user
            if let currentUser = ShareData.init().userdata {
                if currentUser.id == user.id {
                    return
                }
            }
            
            // Safety: if we have user in room, then we of course have a username
            self.coordinator?.showProfileScreen(username: user.username!)
        default: break
        }
    }
}


private enum RoomInfoSection: CaseIterable {
    case generalInfo
    case topicDescription
    case peopleIn
}
