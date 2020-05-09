//
//  TableGrouped.swift
//  Niceter
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
enum TableGroupedSettingsSectionType {
    case profile
    case logout
    
    var headerTitle: String {
        switch self {
        case .profile:
            return "Profile".localized().uppercased()
        default: return ""
        }
    }
}

@frozen
enum TableGroupedCreateRoomSectionType: CaseIterable {
    case permissions
    case ownedCommunities
    case entername
    
    var headerTitle: String {
        switch self {
        case .ownedCommunities:
            return "Owned сommunities".localized().uppercased()
        case .entername:
            return "Name".localized().uppercased()
        default: return ""
        }
    }
}

// MARK: -
@frozen
enum TableGroupedType: String {
    case gitter
    case url
    case email
    case undefined
    case noUrl
    
    // CreateRoom
    case publicPrivate
    case privateMembers
    case ownedCommunities
    case createNewComm
    case enterName
    case enterTopic
}

// MARK: - ItemProtocols
protocol TableGroupedItemProtocol {
    var text: String { get set }
    var type: TableGroupedType { get  set }
    var value: String { get set }
}

struct TableGroupedProfile: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
    var avatarUrl: String
    var user: UserSchema
}

struct TableGroupedItem: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
}

// MARK: - Settings
struct TableGroupedSettingsSection {
    var section: TableGroupedSettingsSectionType
    var items: [TableGroupedItemProtocol]
    var footer: String?
    var grouped: Bool
}

struct TableGroupedCreateRoomSection {
    var section: TableGroupedCreateRoomSectionType
    var items: [TableGroupedItemProtocol]
    var footer: String?
    var grouped: Bool
}

// MARK: - Equatable
extension TableGroupedItemProtocol where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.text == rhs.text
    }
}

extension TableGroupedSettingsSectionType: CustomStringConvertible {
    var description: String {
        return self.headerTitle
    }
}

extension TableGroupedCreateRoomSectionType: CustomStringConvertible {
    var description: String {
        return self.headerTitle
    }
}
