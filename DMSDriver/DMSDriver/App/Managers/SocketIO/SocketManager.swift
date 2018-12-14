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

//MARK: - EMIT
extension SocketService {
    // MARK: - LoginNamespace
    func login(_ id:Int,_ username:String,_ role:String, _ token:String) {
        let  data = ["id":id,"username":username,"role":role,"token":token] as [String:Any]
        print("=====>\(SocketConstants.SOCKET_LOGIN):\(data)<==========")
        loginNamespaceSocket?.emit(SocketConstants.SOCKET_LOGIN, data)
    }
    
    func logout(_ id:Int, _ role:String) {
        let  data = ["id":id,"role":role] as [String:Any]
        print("======>\(SocketConstants.SOCKET_LOGOUT):\(data)<=======")
        loginNamespaceSocket?.emit(SocketConstants.SOCKET_LOGOUT, data)
    }
}



//MARK: - Listening
extension SocketService {
    
    func registerObserveEvent() {
        self.loginNamespaceSocket?.on(SocketConstants.SOCKET_RESULT_LOGIN) {[weak self] (data, ack) in
            self?.resultLogin(data: data)
        }
        
        self.loginNamespaceSocket?.on(SocketConstants.SOCKET_ERROR) {[weak self] (data, ack) in
            self?.handleError(data: data)
        }
        
        self.clientSocket.on(SocketConstants.SOCKET_PACKET) { [weak self] (data, _) in
            let packetData = data.first as? SocketPacket
            packetData?.data
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
