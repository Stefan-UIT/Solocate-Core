//
//  SocketIOManager.swift
//  CiroDoor
//
//  Created by machnguyen_uit on 7/31/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SocketIO

enum NamespaceSocket:String {
    case login = "/login"
}


class SocketService {
    static var shared = SocketService()
    let manager = SocketManager(socketURL: URL(string:BASE_URL_SOCKET())!)
    var defaultSocket:SocketIOClient
    var delegate:APISocketDelegate?
    
    let handleQueue = DispatchQueue(label: "socket_dispatch_queue")
    
    private init(){
        defaultSocket = manager.defaultSocket
    }
    
    func setup() {
        registerGenericEventHandler()
        registerObserveEvent()
    }
    
    private func registerGenericEventHandler() {
        defaultSocket.on(clientEvent: .connect) {[weak self] (data, ack) in
            print("Socket Connected.")
            self?.delegate?.didReceiveConnected(data: data)
        }
        
        defaultSocket.on(clientEvent: .disconnect) { (data, ack) in
            print("Socket Disconnected.")
        }
        
        defaultSocket.on(clientEvent: .reconnect) { (data, ack) in
            print("Socket Reconnected.")
        }
        
        defaultSocket.on(clientEvent: .error) { (data, ack) in
            print("Socket Error: \(data)")
        }
    }
    
    func connect(token: String) {
        let config = SocketIOClientConfiguration(arrayLiteral: .connectParams([DataKey.token: token]),
                                                 .handleQueue(handleQueue),
                                                 .log(SocketConfiguration.log),
                                                 .forceNew(SocketConfiguration.forceNew),
                                                 .secure(SocketConfiguration.secure),
                                                 .path(SocketConfiguration.path),
                                                 .reconnects(SocketConfiguration.reconnect),
                                                 .reconnectAttempts(SocketConfiguration.reconnectAttemp),
                                                 .reconnectWait(SocketConfiguration.reconnectWait))
        manager.config = config
        
        defaultSocket.off(clientEvent: .connect)
        defaultSocket.connect()
        setup()
    }
    
    func socketWithNamespace(_ namespace:NamespaceSocket) -> SocketIOClient {
        return manager.socket(forNamespace: namespace.rawValue)
    }
    
    func disconnect() {
        manager.disconnectSocket(forNamespace: NamespaceSocket.login.rawValue)
        manager.disconnect()
    }
    
    func disconnect(namespace:NamespaceSocket? = nil) {
        if namespace == nil {
            manager.disconnectSocket(forNamespace: namespace!.rawValue)
        }else{
            manager.disconnect()
        }
    }
}
