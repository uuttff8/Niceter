//
//  GitterApi.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

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
        let endpoint = GitterApiLinks.hideRoom(userId: userId, roomId: roomId)
        
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func joinUserChat(username: String, completion: @escaping (RoomSchema) -> Void) {
        let endpoint = GitterApiLinks.joinUserRoom
        
        guard let body =
            """
                {
                "uri":"\(username)"
                }
                """.convertToDictionary() else { return }
        print(body)
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: body)
        { (data) in
            completion(data)
        }
    }
}

// MARK: - Repos
extension GitterApi {
    func getRepos(completion: @escaping ([RepoSchema]) -> Void) {
        genericRequestData(url: GitterApiLinks.repos,
                           method: "GET",
                           body: nil)
        { (data) in
            completion(data)
        }
    }
}

// MARK: - Groups
extension GitterApi {
    func getAdminGroups(completion: @escaping ([GroupSchema]) -> Void) {
        let endpoint = GitterApiLinks.adminGroups
        
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: nil)
        { (data) in
            completion(data)
        }
    }
}

// MARK: - Rooms
extension GitterApi {
    func getRooms(completion: @escaping ([RoomSchema]) -> Void) {
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
        let endpoint = GitterApiLinks.removeUser(userId: userId, roomId: roomId)
        
        genericRequestData(url: GitterApiLinks.removeUser(userId: userId, roomId: roomId),
                           method: endpoint.method,
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func joinRoom(userId: String, roomId: String, completion: @escaping (RoomSchema) -> Void) {
        let endpoint = GitterApiLinks.joinRoom(userId: userId, roomId: roomId)
        
        guard let body =
            """
                {
                "id":"\(roomId)"
                }
                """.convertToDictionary() else { return }
        print(body)        
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: body)
        { (data) in
            completion(data)
        }
    }
    
    func createRoom(
        groupId: String,
        roomName: String,
        topic: String?,
        securityPrivate: Bool,
        privateMembers: Bool,
        completion: @escaping (Result<(), GitterApiErrors.CreateRoomError>) -> Void)
    {
        var securityValue: String
        var typeValue: AnyHashable?
        
        if !securityPrivate && !privateMembers {
            securityValue = "PUBLIC"
            typeValue = "GROUP"
        } else if securityPrivate && privateMembers {
            securityValue = "INHERITED"
            typeValue = "GROUP"
        } else {
            securityValue = "PRIVATE"
        }
        
        
        let securityJson: [String: AnyHashable] = [
            "type": typeValue ?? NSNull() as AnyHashable,
            "linkPath": NSNull(),
            "security": "\(securityValue)"
        ]
        
        var bodyJson: [String: AnyHashable] = [
            "name": "\(roomName)",
            "security": securityJson,
            "addBadge": true
        ]
        
        if let topic = topic {
            bodyJson["topic"] = topic
        }
        
        createRoomRequest(url: GitterApiLinks.createRoom(groupId), body: bodyJson) { (res) in
            completion(res)
        }
    }
    
    func listUsersInRoom(roomId: String, skip: Int, completion: @escaping (([UserSchema]) -> Void)) {
        let endpoint = GitterApiLinks.listUsers(roomId: roomId, skip: skip)
        
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: nil)
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
    
    func sendGitterMessage(
        roomId: String,
        text: String,
        status: Bool = false,
        completion: @escaping (Result<RoomRecreateSchema, GitterApiErrors.MessageFailedError>?) -> Void)
    {
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
        let endpoint = GitterApiLinks.reportMessage(roomId: roomId, messageId: messageId)
        
        genericRequestData(url: endpoint,
                           method: endpoint.method,
                           body: nil)
        { (data) in
            completion(data)
        }
    }
    
    func deleteMessage(roomId: String, messageId: String, completion: @escaping (()) -> Void) {
        deleteMessageRequest(url: GitterApiLinks.deleteMessage(roomId: roomId, messageId: messageId))
        { (_) in
            completion(())
        }
    }
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
                print(data.prettyPrintedJSONString)
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
                guard let decoded = try? self.jsonDecoder.decode(T.self, from: data) else { print("Can't Decode \(T.self) in \(#file) \(#line)"); return }
                completion(decoded)
            default: break
            }
        }
    }
}

// MARK: - Specific Requests
extension GitterApi {
    private func postDataReadMessages<T: Codable>(url: GitterApiLinks, body: [String : Any], completion: @escaping (T) -> Void) {
        //                                     changed link
        let url = URL(string: "\(GitterApiLinks.baseUrlApi2)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.postAuth(url: url, bodyObject: body)
        { (res) in
            switch res {
            case .success(let data):
                guard let type = try? self.jsonDecoder.decode(T.self, from: data) else { print("Can't Decode \(T.self) in \(#file) \(#line)"); return }
                completion(type)
            default: break
            }
        }
    }
    
    private func postDataSendMessage<T>(
        url: GitterApiLinks,
        body: [String : Any],
        completion: @escaping (Result<T, GitterApiErrors.MessageFailedError>) -> Void)
        where
        T: Codable
    {
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
    
    private func deleteMessageRequest(url: GitterApiLinks, completion: @escaping (()) -> Void) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.deleteRequest(url: url, method: "DELETE")
        { (res) in
            switch res {
            case .success(_):
                completion(())
            case .failure(_): break
            }
        }
    }
    
    private func createRoomRequest(url: GitterApiLinks, body: [String : AnyHashable], completion: @escaping (Result<(), GitterApiErrors.CreateRoomError>) -> Void) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)\(url.encode())".encodeUrl)!
        print(String(describing: url))
        
        self.httpClient.genericRequest(url: url, method: "POST", bodyObject: body)
        { (res) in
            switch res {
            case .success(let data):
                if let decoded = try? self.jsonDecoder.decode(ErrorSchema.self, from: data) {
                    
                    // error handling
                    if decoded.error == "Conflict" {
                        completion(.failure(.conflict))
                    } else {
                        completion(.failure(.unknown))
                    }
                    
                } else {
                    completion(.success(()))
                }
            default: break
            }
        }
    }
}

enum GitterApiErrors {
    enum CreateRoomError: Error {
        case conflict
        case unknown
    }
    
    enum MessageFailedError: Error {
        case sendFailed
    }
}
