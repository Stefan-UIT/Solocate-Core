//
//  SocketIOManager.swift
//  CiroDoor
//
//  Created by machnguyen_uit on 7/31/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import SocketIO

let Socket = APISocket.shared


protocol APISocketDelegate {
    func didReceiveResultLogin(data: Any)
}

class APISocket {
    private let manager = SocketManager(socketURL: URL(string:BASE_URL_SOCKET())!)
    static let shared = APISocket()
    let socket:SocketIOClient
    var delegate:APISocketDelegate?
    
    private init(){
        self.socket = manager.defaultSocket
    }
    
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
            
            self.socket.on(SocketConstants.SOCKET_RESULT_LOGIN) { (data, ack) in
                self.resultLogin(data: data)
            }
        }
    }
    
    func disconnectSocket(){
        if(self.socket.status == .connected){
            self.socket.disconnect()
        }
    }
    
    
    //MARK: - Emit
    func login(_ id:Int, _ role:String, _ token:String) {
        let  data = ["id":id,"role":role,"token":token] as [String:Any]
        print("\(SocketConstants.SOCKET_LOGIN):\(data)")
        socket.emit(SocketConstants.SOCKET_LOGIN, data)
    }
    
    func logout(_ id:Int, _ role:String) {
        let  data = ["id":id,"role":role] as [String:Any]
        print("\(SocketConstants.SOCKET_LOGOUT):\(data)")
        socket.emit(SocketConstants.SOCKET_LOGOUT, data)
    }
    
    //MARK: - Receive
    func resultLogin(data:Any) {
        print("==>Result login: \(data)")
        delegate?.didReceiveResultLogin(data: data)
    }
}
