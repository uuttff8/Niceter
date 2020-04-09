//
//  GitterApi.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

@frozen
private enum GitterApiLinks {
    private static let limitMessages = 100 // because limit of unread messages is 100
    
    static let baseUrl = "https://gitter.im/"
    static let baseUrlApi2 = "https://gitter.im/api/"
    static let baseUrlApi = "https://api.gitter.im/"
    
    // Auth
    case exchangeToken
    
    // User
    case user(username: String)
    case whoMe
    case searchUsers(query: String)
    case hideRoom(userId: String, roomId: String)
    case joinUserRoom
    
    // Rooms
    case suggestedRooms
    case rooms
    case readMessages(userId: String, roomId: String)
    case removeUser(userId: String, roomId: String) // This can be self-inflicted to leave the the room and remove room from your left menu.
    case joinRoom(userId: String, roomId: String)
    case searchRooms(_ query: String)
    
    // Messages
    case firstMessages(String)
    case olderMessages(messageId: String, roomId: String)
    case sendMessage(roomId: String)
    case listMessagesAround(roomId: String, messageId: String)
    case listMessagesUnread(roomId: String)
    case reportMessage(roomId: String, messageId: String)
    case deleteMessage(roomId: String, messageId: String)
        
    func encode() -> String {
        switch self {
        case .exchangeToken: return "login/oauth/token"
        case .whoMe: return "v1/user/me"
        case .user(username: let username):
            return "v1/users/\(username)"
        case .searchUsers(query: let query):
            return "v1/user?q=\(query)&type=gitter"
        case .hideRoom(userId: let userId, roomId: let roomId):
            return "v1/user/\(userId)/rooms/\(roomId)"
        case .joinUserRoom:
            return "v1/rooms"
            
        case .rooms: return "v1/rooms"
        case .suggestedRooms: return "v1/user/me/suggestedRooms"
        case .readMessages(userId: let userId, roomId: let roomId):
            return "v1/user/\(userId)/rooms/\(roomId)/unreadItems"
        case .removeUser(userId: let userId, roomId: let roomId):
            return "v1/rooms/\(roomId)/users/\(userId)"
        case .joinRoom(userId: let userId, roomId: _):
            return "v1/user/\(userId)/rooms"
        case .searchRooms(let query):
            return "v1/rooms?q=\(query)"
            
        case .firstMessages(let roomId): return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .olderMessages(messageId: let messageId, roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&beforeId=\(messageId)"
        case .sendMessage(roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages"
        case .listMessagesAround(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)&aroundId=\(messageId)"
        case .listMessagesUnread(roomId: let roomId):
            return "v1/rooms/\(roomId)/chatMessages?limit=\(GitterApiLinks.limitMessages)"
        case .reportMessage(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages/\(messageId)/report"
        case .deleteMessage(roomId: let roomId, messageId: let messageId):
            return "v1/rooms/\(roomId)/chatMessages/\(messageId)"
        }
    }
}

class GitterApi {
    static let shared = GitterApi()
    
    private let appSettings = AppSettingsSecret()
    private let httpClient = HTTPClient()
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - Auth
extension GitterApi {
    func exchangeToken(dataToken: ExchangeTokenSchema, completion: @escaping ((String) -> Void)) {
        print(dataToken)
        let body = try? JSONEncoder().encode(dataToken)
        
        self.httpClient.post(url: URL(string: "\(GitterApiLinks.baseUrl + GitterApiLinks.exchangeToken.encode())")!, params: body!) { (res) in
            switch res {
            case .success(let data):
                let accessToken = try? self.jsonDecoder.decode(AccessTokenSchema.self, from: data).accessToken
                guard let token = accessToken else { print("\(#line) and \(#file) Broken access token"); return }
                completion(token)
            default: break
            }
        }
    }
}

// MARK: - User
extension GitterApi {
    func getWhoMe(completion: @escaping (UserSchema?) -> Void) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)" + "\(GitterApiLinks.whoMe.encode())")!
        
        self.httpClient.getAuth(url: url)
        { (res) in
            switch res {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                
                let user = try? self.jsonDecoder.decode(UserSchema.self, from: data)
                
                completion(user)
            default: print(""); break
            }
        }
    }
    
    func getUser(username: String, completion: @escaping (UserSchema?) -> Void) {
        requestData(url: GitterApiLinks.user(username: username)) { (data) in
            completion(data)
        }
    }
    
    func searchUsers(query: String, completion: @escaping (SearchQuerySchema<UserSchema>?) -> Void) {
        requestData(url: GitterApiLinks.searchUsers(query: query)) { (data) in
            completion(data)
        }
    }
    
    func hideRoom(userId: String, roomId: String, completion: @escaping (SuccessSchema) -> Void) {
        genericRequestData(url: GitterApiLinks.hideRoom(userId: userId, roomId: roomId),
                           method: "DELETE",
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func joinUserChat(username: String, completion: @escaping (RoomSchema) -> Void) {
        guard let body =
            """
                {
                "uri":"\(username)"
                }
                """.convertToDictionary() else { return }
        print(body)
        genericRequestData(url: GitterApiLinks.joinUserRoom,
                           method: "POST",
                           body: body)
        { (data) in
            completion(data)
        }
    }
}


// MARK: - Rooms

extension GitterApi {
    func getRooms(completion: @escaping ([RoomSchema]?) -> Void) {
        requestData(url: GitterApiLinks.rooms) { (data) in
            completion(data)
        }
    }
    
    func getSuggestedRooms(completion: @escaping ([RoomSchema]?) -> Void) {
        requestData(url: GitterApiLinks.suggestedRooms) { (data) in
            completion(data)
        }
    }
    
    func searchRooms(query: String, completion: @escaping (SearchQuerySchema<RoomSchema>?) -> Void) {
        requestData(url: GitterApiLinks.searchRooms(query)) { (data) in
            completion(data)
        }
    }
    
    func markMessagesAsRead(messagesId: [String], roomId: String, userId: String, completion: @escaping (SuccessSchema) -> Void) {
        guard let body =
            """
                {
                "chat": \(messagesId)
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
        print(body)        
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
    func loadFirstMessages(for roomId: String, completion: @escaping ([RoomRecreateSchema]?) -> Void) {
        requestData(url: GitterApiLinks.firstMessages(roomId)) { (data) in
            completion(data)
        }
    }
    
    func loadOlderMessage(messageId: String, roomId: String, completion: @escaping ([RoomRecreateSchema]?) -> Void) {
        requestData(url: GitterApiLinks.olderMessages(messageId: messageId, roomId: roomId)) { (data) in
            completion(data)
        }
    }
    
    func sendGitterMessage(roomId: String, text: String, status: Bool = false, completion: @escaping (Result<RoomRecreateSchema, MessageFailedError>?) -> Void) {
        let bodyObject: [String : Any] = [
            "status": "\(status)",
            "text": "\(text)"
        ]
        
        postDataSendMessage(url: GitterApiLinks.sendMessage(roomId: roomId), body: bodyObject) { (data) in
            completion(data)
        }
    }
    
    func listMessagesAround(messageId: String, roomId: String, completion: @escaping ([RoomRecreateSchema]?) -> Void) {
        requestData(url: GitterApiLinks.listMessagesAround(roomId: roomId, messageId: messageId))
        { (data: [RoomRecreateSchema]?) in
            completion(data)
        }
    }
    
    func listMessagesUnread(roomId: String, completion: @escaping ([RoomRecreateSchema]?) -> Void) {
        requestData(url: GitterApiLinks.listMessagesUnread(roomId: roomId))
        { (data: [RoomRecreateSchema]?) in
            completion(data)
        }
    }
    
    func reportMessage(roomId: String, messageId: String, completion: @escaping (ReportMessageSchema) -> Void) {
        genericRequestData(url: GitterApiLinks.reportMessage(roomId: roomId, messageId: messageId),
                           method: "POST",
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func deleteMessage(roomId: String, messageId: String, completion: @escaping (SuccessSchema) -> Void) {
        genericRequestData(url: GitterApiLinks.deleteMessage(roomId: roomId, messageId: messageId),
                           method: "DELETE",
                           body: nil)
        { (data) in
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
                guard let room = try? self.jsonDecoder.decode(T.self, from: data) else { print("Can't Decode \(T.self) in \(#file) \(#line)"); return }
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
                print(data.prettyPrintedJSONString)
                guard let decoded = try? self.jsonDecoder.decode(T.self, from: data) else { return }
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
                guard let type = try? self.jsonDecoder.decode(T.self, from: data) else { return }
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
                guard let type = try? self.jsonDecoder.decode(T.self, from: data) else { completion(.failure(.sendFailed)); return }
                completion(.success(type))
            case .failure(.fail):
                completion(.failure(.sendFailed))
            }
        }
    }
}

