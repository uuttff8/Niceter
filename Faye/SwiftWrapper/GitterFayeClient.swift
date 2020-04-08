//
//  FayeSwiftClient.swift
//  Gittker
//
//  Created by uuttff8 on 3/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

class GitterFayeClient: NSObject, TREventControllerDelegate {
    
    private var client: TREventController?
    var endpoints: [GitterFayeEndpoints]
    
    init(endpoints: [GitterFayeEndpoints]) {
        self.endpoints = endpoints
        super.init()
        
        connect()
    }
    
    var messageReceivedHandler:((_ messageDict: [AnyHashable : Any], _ channel: String) -> Void)?
    var snapshotReceivedHandler:((_ snapshot: Any, _ channel: String) -> Void)?
    var subscriptionEstablishedHandler:(() -> Void)?
    var subscriptionDisconnectedHandler:(() -> Void)?

    func connect() {
        let stringEndpoints = endpoints.map { (endpoint) -> String in
            return endpoint.encode()
        }
        
        client = TREventController(delegate: self, andChannels: stringEndpoints)
    }
    
    func disconnect() {
        client?.disconnect()
    }
    
    func reconnect() {
        client?.reconnect()
    }
    
    func messageReceived(_ messageDict: [AnyHashable : Any], channel: String) {
        messageReceivedHandler?(messageDict, channel)
    }
    
    func snapshotReceived(_ snapshot: Any, channel: String) {
        snapshotReceivedHandler?(snapshot, channel)
    }
    
    func serverSubscriptionEstablished() {
        subscriptionEstablishedHandler?()
    }
    
    func serverSubscriptionDisconnected() {
        subscriptionDisconnectedHandler?()
    }
    
}
