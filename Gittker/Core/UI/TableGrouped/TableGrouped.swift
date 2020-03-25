//
//  TableGrouped.swift
//  Gittker
//
//  Created by uuttff8 on 3/25/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

enum TableGroupedSectionType: String {
    // About
    case profile = "Profile"
//    case contributors = "Contributors"
    case licenses = "Licenses"
//    case evolution = "Evolution App"
//    case swiftEvolution = "Swift Evolution"
//    case thanks = "Thanks to"
    case application = "Application"
    
    // Settings
//    case notifications = "Notifications"
//    case openSource = "Open Source"
    case about = "About"
}

// MARK: -
enum TableGroupedType: String {
    case gitter
    case url
    case email
    case undefined
    case noUrl
}

// MARK: - ItemProtocols
protocol TableGroupedItemProtocol {
    var text: String { get set }
    var type: TableGroupedType { get  set }
    var value: String { get set }
}

struct TableGroupedContributor: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
    var avatarUrl: String
}

struct TableGroupedLicense: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
}

struct TableGroupedItem: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
}

struct TableGroupedSubscription: TableGroupedItemProtocol {
    var text: String
    var type: TableGroupedType
    var value: String
    var subscribed: Bool
}

// MARK: -
struct TableGroupedSection {
    var section: TableGroupedSectionType
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

extension TableGroupedSectionType: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
