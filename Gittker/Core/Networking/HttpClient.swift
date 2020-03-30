//
//  HttpClient.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import KeychainSwift

enum CustomHttpError: Error {
    case fail
}

protocol HTTPClientProvider {
    func get(url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ()))
    func post(url: URL, params: Data, completion: @escaping ((Result<Data, CustomHttpError>)-> ())) 
}

final class HTTPClient: HTTPClientProvider {
    private let keychain = KeychainSwift()
    
    func get(url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
    func getAuth(url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        guard let accessToken = LoginData.shared.accessToken else {
            print("Access Token is not provided")
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [ "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json",
            "Content-Type": "application/json"]
        
        let request = URLRequest(url: url)
        
        URLSession(configuration: config,
                   delegate:nil,
                   delegateQueue: OperationQueue.current)
            .dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    
                    completion(.success(data))
                }
        }.resume()
    }
    
    func post(url: URL, params: Data, completion: @escaping ((Result<Data, CustomHttpError>)-> ())) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
    func postAuth(url: URL, bodyObject: [String : Any],  completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        guard let accessToken = LoginData.shared.accessToken else {
            print("Access Token is not provided")
            return
        }
        guard let jsonBody = try? JSONSerialization.data(withJSONObject: bodyObject, options: []) else { return }
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [ "Authorization": "Bearer \(accessToken)",
                                         "Accept": "application/json",
                                         "Content-Type": "application/json"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        
        URLSession(configuration: config,
                   delegate: INetworkDelegate(),
                   delegateQueue: OperationQueue.current)
            .dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    completion(.success(data))
                }
        }.resume()
    }
    
    func genericRequest(url: URL, method: String, bodyObject: [String: Any]?, completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        guard let accessToken = LoginData.shared.accessToken else {
            print("Access Token is not provided")
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [ "Authorization": "Bearer \(accessToken)",
                                         "Accept": "application/json",
                                         "Content-Type": "application/json"]
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let bodyObject = bodyObject {
            guard let jsonBody = try? JSONSerialization.data(withJSONObject: bodyObject, options: []) else { return }
            request.httpBody = jsonBody
        }
        
        URLSession(configuration: config,
                   delegate: INetworkDelegate(),
                   delegateQueue: OperationQueue.current)
            .dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    completion(.success(data))
                }
        }.resume()
    }
}


private class INetworkDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("waiting")
    }
}
