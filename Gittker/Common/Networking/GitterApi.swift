//
//  GitterApi.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

private enum GitterApiLinks: String {
    static let baseUrl = "https://gitter.im/"
    static let baseUrlApi = "https://api.gitter.im/"
    
    
    case exchangeToken = "login/oauth/token"
    case whoMe = "v1/user/me"
    case rooms = "/v1/rooms"
}

class GitterApi {
    static let shared = GitterApi()
    
    private let appSettings = AppSettingsSecret()
    private let httpClient = HTTPClient()
}

// MARK: - Auth
extension GitterApi {
    func exchangeToken(dataToken: ExchangeToken, completion: @escaping ((String) -> Void)) {
        print(dataToken)
        let body = try? JSONEncoder().encode(dataToken)
        
        self.httpClient.post(url: URL(string: "\(GitterApiLinks.baseUrl + GitterApiLinks.exchangeToken.rawValue)")!, params: body!) { (res) in
            switch res {
            case .success(let data):
                let accessToken = try? JSONDecoder().decode(AccessToken.self, from: data).accessToken
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
    func getUserId(completion: @escaping ((User?) -> Void)) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)" + "\(GitterApiLinks.whoMe.rawValue)")!
        print(String(describing: url))
        
        self.httpClient.getAuth(url: url)
        { (res) in
            switch res {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                
                let user = try? JSONDecoder().decode(User.self, from: data)
                
                completion(user)
            default: print(""); break
            }
        }
    }
}


// MARK: - Rooms

extension GitterApi {
    func getRooms(completion: @escaping (([RoomSchema]?) -> Void)) {
        let url = URL(string: "\(GitterApiLinks.baseUrlApi)" + "\(GitterApiLinks.rooms.rawValue)")!
        print(String(describing: url))
        
        self.httpClient.getAuth(url: url)
        { (res) in
            switch res {
                case .success(let data):
                    let str = String(decoding: data, as: UTF8.self)
                    print(str)
                    
                    let room = try! JSONDecoder().decode([RoomSchema].self, from: data)
                    
                    completion(room)
                default: break
            }
        }
    }
}
