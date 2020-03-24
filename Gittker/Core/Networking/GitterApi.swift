//
//  GitterApi.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

private enum GitterApiLinks {
    private static let limitMessages = 30 // Limit messages to be loaded
    
    static let baseUrl = "https://gitter.im/"
    static let baseUrlApi = "https://api.gitter.im/"
    
    case exchangeToken
    case whoMe
    case suggestedRooms
    case rooms
    
    // Messages
    case firstMessages(String)
    case olderMessages(messageId: String, roomId: String)
    
    func encode() -> String {
        switch self {
        case .firstMessages(let roomId): return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .olderMessages(messageId: let messageId, roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&beforeId=\(messageId)"
        case .exchangeToken: return "login/oauth/token"
        case .rooms: return "v1/rooms"
        case .suggestedRooms: return "v1/user/me/suggestedRooms"
        case .whoMe: return "v1/user/me"
        }
    }
}

class GitterApi {
    static let shared = GitterApi()
    
    private let appSettings = AppSettingsSecret()
    private let httpClient = HTTPClient()
}

// MARK: - Auth
extension GitterApi {
    func exchangeToken(dataToken: ExchangeTokenSchema, completion: @escaping ((String) -> Void)) {
        print(dataToken)
        let body = try? JSONEncoder().encode(dataToken)
        
        self.httpClient.post(url: URL(string: "\(GitterApiLinks.baseUrl + GitterApiLinks.exchangeToken.encode())")!, params: body!) { (res) in
            switch res {
            case .success(let data):
                let accessToken = try? JSONDecoder().decode(AccessTokenSchema.self, from: data).accessToken
                guard let token = accessToken else { print("\(#line) and \(#file) Broken access token"); return }
                completion(token)
            default: break
            }
        }
    }
    
    func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
}

// MARK: - User
extension GitterApi {
    func getUserId(completion: @escaping ((UserSchema?) -> Void)) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)" + "\(GitterApiLinks.whoMe.encode())")!
        
        self.httpClient.getAuth(url: url)
        { (res) in
            switch res {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                
                let user = try? JSONDecoder().decode(UserSchema.self, from: data)
                
                completion(user)
            default: print(""); break
            }
        }
    }
}


// MARK: - Rooms

extension GitterApi {
    func getRooms(completion: @escaping (([RoomSchema]?) -> Void)) {
        requestData(url: GitterApiLinks.rooms) { (data) in
            completion(data)
        }
    }
    
    func getSuggestedRooms(completion: @escaping (([RoomSchema]?) -> Void)) {
        requestData(url: GitterApiLinks.suggestedRooms) { (data) in
            completion(data)
        }
    }
}

// MARK: - Messages
extension GitterApi {
    func loadFirstMessages(for roomId: String, completion: @escaping (([RoomRecreateSchema]?) -> Void)) {
        requestData(url: GitterApiLinks.firstMessages(roomId)) { (data) in
            completion(data)
        }
    }
    
    func loadOlderMessage(messageId: String, roomId: String, completion: @escaping (([RoomRecreateSchema]?) -> Void)) {
        requestData(url: GitterApiLinks.olderMessages(messageId: messageId, roomId: roomId)) { (data) in
            completion(data)
        }
    }
}


// MARK: - Private -
extension GitterApi {
    private func requestData<T: Codable>(url: GitterApiLinks, completion: @escaping (T) -> ()) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)" + url.encode())!
        print(String(describing: url))
        
        self.httpClient.getAuth(url: url)
        { (res) in
            switch res {
            case .success(let data):
                let room = try! JSONDecoder().decode(T.self, from: data)
                completion(room)
            default: break
            }
        }
    }
}
