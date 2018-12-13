//
//  SocketManager.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/13/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation
import SocketIO

protocol APISocketDelegate {
    func didReceiveResultLogin(data: Any)
    func didReceiveError(data: String)
    
}

// MARK: - EMIT
extension SocketService {
    func login(_ id:Int, _ role:String, _ token:String) {
        let  data = ["id":id,"role":role,"token":token] as [String:Any]
        print("==>\(SocketConstants.SOCKET_LOGIN):\(data)")
        clientSocket.emit(SocketConstants.SOCKET_LOGIN, data)
    }
    
    func logout(_ id:Int, _ role:String) {
        let  data = ["id":id,"role":role] as [String:Any]
        print("===>\(SocketConstants.SOCKET_LOGOUT):\(data)")
        clientSocket.emit(SocketConstants.SOCKET_LOGOUT, data)
    }
}


//MARK: - Listening
extension SocketService {
    
    func registerObserveEvent() {
        self.clientSocket.on(SocketConstants.SOCKET_RESULT_LOGIN) {[weak self] (data, ack) in
            self?.resultLogin(data: data)
        }
        
        self.clientSocket.on(SocketConstants.SOCKET_ERROR) {[weak self] (data, ack) in
            self?.handleError(data: data)
        }
    }
    
    func resultLogin(data:Any) {
        print("==>Result login: \(data)")
        delegate?.didReceiveResultLogin(data: data)
    }
    
    func handleError(data: Any) {
        print("==>Error socket: \(data)")
        if let result = data as? ResponseArray {
            var mess = ""
            result.forEach { (error) in
                if let _error = error as? String {
                    mess = mess + _error
                }
            }
            delegate?.didReceiveError(data: mess)
        }
    }
}

/*
func establishConnection(token:String? = nil){
    if(self.socket.status != .connected){
        if let _token = token{
            self.manager.config = SocketIOClientConfiguration(arrayLiteral: .forceNew(false),
                                                              .reconnects(true),
                                                              .secure(true),
                                                              .path("/session/socket.io"),
                                                              .compress,
                                                              .connectParams(["token": _token]))
        }else{
            self.manager.config = SocketIOClientConfiguration(arrayLiteral: .forceNew(false),
                                                              .reconnects(true),
                                                              .secure(true),
                                                              .path("/session/socket.io"),
                                                              .compress)
            
        }
        self.socket.connect()
        
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print("Socket Connected.")
        }
        
        self.socket.on(clientEvent: .disconnect) { (data, ack) in
            print("Socket Disconnected.")
        }
        
        self.socket.on(clientEvent: .reconnect) { (data, ack) in
            print("Socket Reconnected.")
        }
        self.socket.on(clientEvent: .error) { (data, ack) in
            print("Socket Error: \(data)")
        }
        
   
    }
}
 */
