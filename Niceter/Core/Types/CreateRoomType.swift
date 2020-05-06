//
//  CreateRoomType.swift
//  Niceter
//
//  Created by uuttff8 on 5/6/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

struct CreateRoomType {
    enum Errors: Error {
        case noCommunity
        case noName
        case wrongName
        
        var localizedDescription: String {
            switch self {
            case .noCommunity:
                return "Please, specify community".localized()
            case .noName:
                return "Room name is not entered".localized()
            case .wrongName:
                return "Names must be alphanumeric with no spaces. Dashes are allowed".localized()
            }
        }
    }
    
    let community: GroupSchema
    let roomName: String
    
    init?(community: GroupSchema?, roomName: String?, failure: (Error) -> Void) {
        guard let community = community else {
            failure(Self.Errors.noCommunity)
            return nil
        }
        
        guard let text = roomName else {
            failure(Self.Errors.noName)
            return nil
        }
        
        guard text.rangeOfCharacter(from: CharacterSet.gitterValidRoomName.inverted) == nil else {
            failure(Self.Errors.wrongName)
            return nil
        }
        
        self.community = community
        self.roomName = text
    }
}

private extension CharacterSet {
    static var gitterValidRoomName: NSMutableCharacterSet {
        let validRoomNameCharacters = NSMutableCharacterSet()
        validRoomNameCharacters.formUnion(with: CharacterSet.alphanumerics)
        validRoomNameCharacters.addCharacters(in: "-")
        return validRoomNameCharacters
    }
}
