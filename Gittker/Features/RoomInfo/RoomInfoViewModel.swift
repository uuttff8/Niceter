//
//  RoomInfoViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoViewModel: NSObject {
    weak var coordinator: RoomInfoCoordinator?
    
    let roomSchema: RoomSchema
    let roomSchemaPeople = DynamicValue<[UserSchema]>([])
    
    init(coordinator: RoomInfoCoordinator, roomSchema: RoomSchema, prefetchedUsers: [UserSchema]) {
        self.coordinator = coordinator
        self.roomSchema = roomSchema
        self.roomSchemaPeople.value = prefetchedUsers
        super.init()
    }
    
    func loadMorePeople() {
        GitterApi.shared.listUsersInRoom(roomId: roomSchema.id, skip: roomSchemaPeople.value.count) { userSchemaList in
            self.roomSchemaPeople.value = userSchemaList
        }
    }
}


extension RoomInfoViewModel: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return RoomInfoSection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch RoomInfoSection.allCases[section] {
        case .peopleIn: return self.roomSchemaPeople.value.count
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
                let user = self.roomSchemaPeople.value[indexPath.row]
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
            let user = self.roomSchemaPeople.value[indexPath.row]
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
