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
    static let SERVER_DEV = "http://dms-customization.dev.seldatdirect.com"
    static let SERVER_PROD = "http://dms-customization.seldatdirect.com"
    static let SOCKET_LOGIN = "request-login"
    static let SOCKET_LOGOUT = "request-logout"
    static let SOCKET_RESULT_LOGIN = "result-login"
    static let SOCKET_ERROR = "error"
    static let SOCKET_PACKET = "packet"
    
    static let messangeNeedRelogines = ["Token invalid.","Token did not supply."]

    
    static var PATH:String {
        get {
            let type = SDBuildConf.buildScheme
            switch type {
            case .debug,
                 .adhoc:
                return "/session/socket.io"
            case .staging:
                return "/session/socket.io/socket.io.js"
            case .release:
                return "/session/socket.io/socket.io.js"
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
