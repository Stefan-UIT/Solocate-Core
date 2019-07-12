//
//  SocketConstants.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 12/13/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation


struct SocketConfiguration {
    static let forceNew = false
    static let log = false
    static let secure = false
    static let reconnect = true
    static let reconnectAttemp = 5
    static let reconnectWait = 2
    static let path = "/session/socket.io"
}

// SOCKET KEY
struct SocketConstants {
    static let SERVER_DEV = "http://solocate.ashdodb.dev.seldatdirect.com"
    static let SERVER_QC = "http://solocate-a1.qc.seldatdirect.com"
    static let SERVER_DEMO = "http://solocate-a1.demo.seldatdirect.com"
    static let SERVER_PROD = "http://dms-customization.seldatdirect.com"
    static let SOCKET_LOGIN = "request-login"
    static let SOCKET_LOGOUT = "request-logout"
    static let SOCKET_RESULT_LOGIN = "result-login"
    static let SOCKET_ERROR = "error"
    static let SOCKET_PACKET = "packet"
    
    static let messangeNeedRelogines = ["Token invalid.","Token did not supply."]

    
    static var PATH:String {
        get {
            return "/session/socket.io"
        }
    }
    
    static var BASE_URL_SOCKET:String {
        get{
            let type = SDBuildConf.serverEnvironment
            switch type {
            case .development:
                return SocketConstants.SERVER_DEV
            case .qc:
                return SocketConstants.SERVER_QC
            case .demo:
                return SocketConstants.SERVER_DEMO
            case .production:
                return SocketConstants.SERVER_PROD
            }
        }
    }
}



struct DataKey {
    static let token = "token"
    struct SendMessage {
        static let receiverId = "receiverId"
        static let msg = "desc"
        static let fileId = "fileId"
    }
    
    struct Typing {
        static let receiverId = "receiverId"
        static let typing = "type"
    }
    
    struct Edit {
        static let msgId = "msgId"
        static let msg = "desc"
    }
    
    struct Delete {
        static let msgId = "msgId"
    }
}
