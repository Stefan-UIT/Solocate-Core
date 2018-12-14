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
    var clientSocket:SocketIOClient
    var loginNamespaceSocket:SocketIOClient?
    var delegate:APISocketDelegate?
    
    let handleQueue = DispatchQueue(label: "socket_dispatch_queue")
    
    private init(){
        clientSocket = manager.defaultSocket
        loginNamespaceSocket = manager.socket(forNamespace: NamespaceSocket.login.rawValue)
    }
    
    func setup() {
        registerGenericEventHandler()
        registerObserveEvent()
    }
    
    private func registerGenericEventHandler() {
        clientSocket.on(clientEvent: .connect) { (data, ack) in
            print("Socket Connected.")
        }
        
        clientSocket.on(clientEvent: .disconnect) { (data, ack) in
            print("Socket Disconnected.")
        }
        
        clientSocket.on(clientEvent: .reconnect) { (data, ack) in
            print("Socket Reconnected.")
        }
        
        clientSocket.on(clientEvent: .error) { (data, ack) in
            print("Socket Error: \(data)")
        }
    }
    
    func connect(token: String) {
        let config = SocketIOClientConfiguration(arrayLiteral: .connectParams([DataKey.token: token]),
                                                 .handleQueue(handleQueue),
                                                 .log(SocketConfiguration.log),
                                                 .secure(SocketConfiguration.secure),
                                                 .path(SocketConfiguration.path),
                                                 .reconnects(SocketConfiguration.reconnect),
                                                 .reconnectAttempts(SocketConfiguration.reconnectAttemp),
                                                 .reconnectWait(SocketConfiguration.reconnectWait))
        manager.config = config
        clientSocket.connect()
        loginNamespaceSocket?.connect()
        setup()
    }
    
    func disconnect(namespace:NamespaceSocket? = nil) {
        if namespace == nil {
            manager.disconnectSocket(forNamespace: namespace!.rawValue)
        }else{
            manager.disconnect()
        }
    }
}
