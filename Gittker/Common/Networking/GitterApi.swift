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
}

class GitterApi {
    private let appSettings = AppSettingsSecret()
    private let httpClient = HTTPClient()
    private let accessToken: String?
    
    init(accessToken: String?) {
        self.accessToken = accessToken
    }
    
    private func authSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = [ "Authorization": "Bearer \(accessToken)" ]
        
        return URLSession(configuration: config, delegate:nil, delegateQueue:OperationQueue.main)
    }
    
}

// MARK: - Auth
extension GitterApi {
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func exchangeToken(dataToken: ExchangeToken, completion: @escaping ((String) -> Void)) {
        print(dataToken)
        let body = try? JSONEncoder().encode(dataToken)
        
        self.httpClient.post(url: URL(string: "\(GitterApiLinks.baseUrl + GitterApiLinks.exchangeToken.rawValue)")!, params: body!) { (res) in
            switch res {
            case .success(let data):
                let respJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let respDic = respJson as? [String: Any] {
                    print(respDic)
                    completion(respDic["access_token"] as! String)
                }
            default: print("pizdec"); break
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
    
    func getUserId(completion: @escaping ((User?) -> Void)) {
        var url = URLComponents(string: "\(GitterApiLinks.baseUrlApi)" + "\(GitterApiLinks.whoMe.rawValue)")!

        url.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken)
        ]
        
        print(url.url!)
        self.httpClient.getAuth(accessToken: self.accessToken ?? "",
                                url: url.url!)
        { (res) in
            switch res {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                
                let user = try? JSONDecoder().decode(User.self, from: data)
                
                completion(user)
            default: print("pizdec 2"); break
            }
        }
    }
}
