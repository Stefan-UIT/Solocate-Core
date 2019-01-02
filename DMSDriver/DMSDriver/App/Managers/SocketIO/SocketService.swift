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
        clearAllHandle()
        
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
        defaultSocket.connect()
        setup()
    }
    
    func socketWithNamespace(_ namespace:NamespaceSocket) -> SocketIOClient {
        return manager.socket(forNamespace: namespace.rawValue)
    }
    
    func clearAllHandle() {
        clearAllHandle(defaultSocket)
        clearAllHandle(socketWithNamespace(.login))
    }
    
    func clearAllHandle(_ socket:SocketIOClient) {
        socket.off(clientEvent: .connect)
        socket.off(clientEvent: .disconnect)
        socket.off(clientEvent: .error)
        socket.off(clientEvent: .reconnect)
        socket.off(SocketConstants.SOCKET_RESULT_LOGIN)
        socket.off(SocketConstants.SOCKET_ERROR)
        socket.off(SocketConstants.SOCKET_PACKET)
    }
    
    func disconnect() {
        clearAllHandle()
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
