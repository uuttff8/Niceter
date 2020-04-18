//
//  RoomInfoViewModel.swift
//  Gittker
//
//  Created by uuttff8 on 4/18/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomInfoViewModel: NSObject {
    let roomSchema: RoomSchema
    let roomSchemaPeople = DynamicValue<[UserSchema]>([])
    
    init(roomSchema: RoomSchema) {
        self.roomSchema = roomSchema
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
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            switch RoomInfoSection.allCases[indexPath.section] {
            case .generalInfo:
                return RoomInfoGeneralInfoNode(with: self.roomSchema)
            case .peopleIn:
                guard let topic = self.roomSchema.topic, !topic.isEmpty else {
                    return ASCellNode()
                }
                
                return RoomInfoTopicNode(with: topic)
            case .topicDescription:
                return ASCellNode()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}


private enum RoomInfoSection: CaseIterable {
    case generalInfo
    case topicDescription
    case peopleIn
}
