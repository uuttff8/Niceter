//
//  GitterFayeClient.swift
//  Gittker
//
//  Created by uuttff8 on 3/10/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation
import GFayeSwift
import KeychainSwift
import Starscream

class GitterFayeClient {
    let keychain = KeychainSwift()
    let client:GFayeClient = GFayeClient(aGFayeURLString: "https://ws.gitter.im/faye")
    
    var accessToken: String? {
        keychain.get(ShareDataConstants.accessToken)
    }
    
    init () {
        let socket = WebSocket(url: URL(string: "https://ws.gitter.im/faye")!)
        socket.delegate = self
        socket.connect()

        
//        client.delegate = self;
//        client.transportHeaders = ["X-Custom-Header": "Custom Value"]
//        client.connectToServer()
//
//        let channelBlock:ChannelSubscriptionBlock = {(messageDict) -> Void in
//            if let text = messageDict["text"] {
//                print("Here is the Block message: \(text)")
//            }
//        }
//        //        _ = client.subscribeToChannel("/cool")
//        _ = client.subscribeToChannel("/api/v1/rooms/5e679403d73408ce4fdc403a/chatMessages", block: channelBlock)
//
//        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            self.client.unsubscribeFromChannel("/api/v1/rooms/5e679403d73408ce4fdc403a/chatMessages")
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            let model = GFayeSubscriptionModel(subscription: "/api/v1/rooms/5e679403d73408ce4fdc403a/chatMessages",
//                                               channel: .handshake,
//                                               clientId: nil,
//                                               ext: ["token": self.accessToken!])
//
//            _ = self.client.subscribeToChannel(model, block: { [unowned self] messages in
//                print("awesome response: \(messages)")
//
//                self.client.sendPing("Ping".data(using: String.Encoding.utf8)!, completion: {
//                    print("got pong")
//                })
//            })
//        }
        
    }
}


extension GitterFayeClient: GFayeClientDelegate {
    func connectedtoser(_ client: GFayeClient) {
        print("Connected to Faye server")
    }
    
    func connectionFailed(_ client: GFayeClient) {
        print("Failed to connect to Faye server!")
    }
    
    func disconnectedFromServer(_ client: GFayeClient) {
        print("Disconnected from Faye server")
    }
    
    func didSubscribeToChannel(_ client: GFayeClient, channel: String) {
        print("Subscribed to channel \(channel)")
    }
    
    func didUnsubscribeFromChannel(_ client: GFayeClient, channel: String) {
        print("Unsubscribed from channel \(channel)")
    }
    
    func subscriptionFailedWithError(_ client: GFayeClient, error: SubscriptionError) {
        print("Subscription failed")
    }
    
    func messageReceived(_ client: GFayeClient, messageDict: GFayeMessage, channel: String) {
        print("Message received: \(messageDict)")
        if let text = messageDict["text"] {
            print("Here is the message: \(text)")
            print("\(channel): \(text)\n")
        }
    }
    
    func pongReceived(_ client: GFayeClient) {
        print("pong")
    }
}

extension GitterFayeClient: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print(#function)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print(#function)
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(#function)
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(#function)
        
    }
    
    
}
