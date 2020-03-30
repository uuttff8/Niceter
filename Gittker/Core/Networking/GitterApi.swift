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
    static let baseUrlApi2 = "https://gitter.im/api/"
    static let baseUrlApi = "https://api.gitter.im/"
    
    // Auth
    case exchangeToken
    case whoMe
    
    // Rooms
    case suggestedRooms
    case rooms
    case readMessages(userId: String, roomId: String)
    case removeUser(userId: String, roomId: String) // This can be self-inflicted to leave the the room and remove room from your left menu.
    case joinRoom(userId: String, roomId: String)
    
    // Messages
    case firstMessages(String)
    case olderMessages(messageId: String, roomId: String)
    case sendMessage(roomId: String)
    
    // Search Rooms
    case searchRooms(_ query: String)
    
    func encode() -> String {
        switch self {
        case .firstMessages(let roomId): return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .olderMessages(messageId: let messageId, roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&beforeId=\(messageId)"
        case .sendMessage(roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages"
            
        case .exchangeToken: return "login/oauth/token"
        case .whoMe: return "v1/user/me"
            
        case .rooms: return "v1/rooms"
        case .suggestedRooms: return "v1/user/me/suggestedRooms"
        case .readMessages(userId: let userId, roomId: let roomId):
            return "v1/user/\(userId)/rooms/\(roomId)/unreadItems"
        case .removeUser(userId: let userId, roomId: let roomId):
            return "v1/rooms/\(roomId)/users/\(userId)"
        case .joinRoom(userId: let userId, roomId: _):
            return "v1/user/\(userId)/rooms"
        
        case .searchRooms(let query): return "v1/rooms?q=\(query)"
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
    
    func searchRooms(query: String, completion: @escaping (SearchQuerySchema?) -> Void) {
        requestData(url: GitterApiLinks.searchRooms(query)) { (data) in
            completion(data)
        }
    }
    
    func markMessagesAsRead(roomId: String, userId: String, completion: @escaping ((SuccessSchema) -> Void)) {
        guard let body =
        """
        {
          "chat": [
            "\(roomId)"
          ]
        }
        """.convertToDictionary() else { return }
        
        postDataReadMessages(url: GitterApiLinks.readMessages(userId: userId, roomId: roomId), body: body) { (data: SuccessSchema) in
            completion(data)
        }
    }
    
    func removeUserFromRoom(userId: String, roomId: String, completion: @escaping (SuccessSchema) -> Void) {
        genericRequestData(url: GitterApiLinks.removeUser(userId: userId, roomId: roomId),
                           method: "DELETE",
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func joinRoom(userId: String, roomId: String, completion: @escaping (RoomSchema) -> Void) {
        guard let body =
        """
        {
            "id":"\(roomId)"
        }
        """.convertToDictionary() else { return }
        
        genericRequestData(url: GitterApiLinks.joinRoom(userId: userId, roomId: roomId),
                           method: "POST",
                           body: body)
        { (data) in
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
    
    func sendGitterMessage(roomId: String, text: String, status: Bool = false, completion: @escaping ((Result<RoomRecreateSchema, MessageFailedError>?) -> Void)) {
        let bodyObject: [String : Any] = [
            "status": "\(status)",
            "text": "\(text)"
        ]
        
        postDataSendMessage(url: GitterApiLinks.sendMessage(roomId: roomId), body: bodyObject) { (data) in
            completion(data)
        }
    }
}


enum MessageFailedError: Error {
    case sendFailed
}

// MARK: - Private -
extension GitterApi {
    private func requestData<T: Codable>(url: GitterApiLinks, completion: @escaping (T) -> ()) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)\(url.encode())".encodeUrl)!
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
    
    private func genericRequestData<T: Codable>(url: GitterApiLinks, method: String, body: [String: Any]?, completion: @escaping (T) -> ()) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.genericRequest(url: url, method: method, bodyObject: body)
        { (res) in
            switch res {
            case .success(let data):
                let decoded = try! self.newJSONDecoder().decode(T.self, from: data)
                completion(decoded)
            default: break
            }
        }
    }
}

// MARK: - Specific Requests
extension GitterApi {
    private func postDataReadMessages<T: Codable>(url: GitterApiLinks, body: [String : Any], completion: @escaping (T) -> ()) {
        //                                     changed link
        let url = URL(string: "\(GitterApiLinks.baseUrlApi2)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.postAuth(url: url, bodyObject: body)
        { (res) in
            switch res {
            case .success(let data):
                guard let type = try? JSONDecoder().decode(T.self, from: data) else { return }
                completion(type)
            default: break
            }
        }
    }
    
    private func postDataSendMessage<T: Codable>(url: GitterApiLinks, body: [String : Any], completion: @escaping (Result<T, MessageFailedError>) -> ()) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.postAuth(url: url, bodyObject: body)
        { (res) in
            switch res {
            case .success(let data):
                guard let type = try? JSONDecoder().decode(T.self, from: data) else { completion(.failure(.sendFailed)); return }
                completion(.success(type))
            case .failure(.fail):
                completion(.failure(.sendFailed))
            }
        }
    }
}

