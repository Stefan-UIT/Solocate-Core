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
    func didReceiveConnected(data: Any)
    func didReceiveResultLogin(data: Any)
    func didReceiveError(data: String)
}

extension APISocketDelegate{
    func didReceiveConnected(data: Any){}
    func didReceiveResultLogin(data: Any){}
    func didReceiveError(data: String){}
}


// MARK: - LoginNamespace
extension SocketService {
    func login(_ id:Int,_ username:String,_ role:String, _ token:String, _ userInfo:UserModel.UserInfo
        ) {
        let loginNamespaceSocket = socketWithNamespace(.login)
        loginNamespaceSocket.on(clientEvent: .connect) { (data, _) in
//            let  data = ["id":id,"username":username,"role":role,"token":token] as [String:Any]
            let  data = ["id":id,"username":userInfo.toJSON(),"role":role,"token":token] as [String:Any]
            loginNamespaceSocket.emit(SocketConstants.SOCKET_LOGIN, data)

            print("Connected login namespace socket")
            print("======>\(SocketConstants.SOCKET_LOGIN):\(data)<==========")
        }
        
        loginNamespaceSocket.on(clientEvent: .error) { (data, _) in
            print("Error Login Namespace Socket")
        }
        
        loginNamespaceSocket.on(SocketConstants.SOCKET_RESULT_LOGIN) {[weak self] (data, ack) in
            self?.resultLogin(data: data)
        }
        
        loginNamespaceSocket.on(SocketConstants.SOCKET_ERROR) {[weak self] (data, ack) in
            self?.handleError(data: data)
        }
        
        loginNamespaceSocket.connect()
    }
    
    func logout(_ id:Int, _ role:String) {
        let data = ["id":id,"role":role] as [String:Any]
        print("======>\(SocketConstants.SOCKET_LOGOUT):\(data)<=======")

        let loginNamespaceSocket = manager.socket(forNamespace: NamespaceSocket.login.rawValue)
        loginNamespaceSocket.emit(SocketConstants.SOCKET_LOGOUT, data)
    }
}



//MARK: - Listening
extension SocketService {
    
    func registerObserveEvent() {
        self.defaultSocket.on(SocketConstants.SOCKET_PACKET) {(data, _) in
            let packetData = data.first as? SocketPacket
            print(packetData)
        }
    }
    
    func resultLogin(data:Any) {
        print("========>Result login: \(data)<============")
        delegate?.didReceiveResultLogin(data: data)
    }
    
    func handleError(data: Any) {
        print("=======>Error socket: \(data)<========")
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
