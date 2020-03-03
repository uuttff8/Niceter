//
//  HttpClient.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

enum CustomHttpError: Error {
    case fail
}

protocol HTTPClientProvider {
    func get(url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ()))
    func post(url: URL, params: Data, completion: @escaping ((Result<Data, CustomHttpError>)-> ())) 
}

final class HTTPClient: HTTPClientProvider {
    
    func get(url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
    func getAuth(accessToken: String, url: URL, completion: @escaping ((Result<Data, CustomHttpError>) -> ())) {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = [ "Authorization": "Bearer \(accessToken)",
                                         "Accept": "application/json",
                                         "Content-Type": "application/json"]

        var request = URLRequest(url: url)
        
        
        URLSession(configuration: config,
                   delegate:nil,
                   delegateQueue:OperationQueue.main)
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
}
