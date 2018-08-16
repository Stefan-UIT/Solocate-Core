	//
//  RESTConstants.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
// Malee:
/*
 https://apigw.seldatdirect.com/demo/sdms-malee/api
 https://apigw.seldatdirect.com/dev/sdms-malee/api
 */

// Masof
/*
 https://apigw.seldatdirect.com/dev/sdms-masof/api
 */

typealias JSONData = [String: Any]
typealias OnCompletion = (_ successful: Bool, _ data: Any?) -> Void


enum PATH_REQUEST_URL: String{
    case LOGIN = "LOGIN"
    case FORGET_PASSWORD = "FORGET_PASSWORD"
    case LOGOUT = "LOGOUT"
    case GET_ORDERS = "GET_ORDERS"
    case GET_ORDER_BY_DATE = "GET_ORDER_BY_DATE"
    case GET_ORDER_BY_COORDINATOR = "GET_ORDER_BY_COORDINATOR"
    case GET_ROUTES_BY_DATE = "GET_ROUTES_BY_DATE"
    case GET_ROUTE_BY_COORDINATOR = "GET_ROUTE_BY_COORDINATOR"
    case GET_PACKAGES_IN_ROUTE = "GET_PACKAGES_IN_ROUTE"
    case GET_ORDER_DETAIL = "GET_ORDER_DETAIL"
    case UPDATE_ORDER_STATUS = "UPDATE_ORDER_STATUS"
    case UPLOAD_SIGNATURE = "UPLOAD_SIGNATURE"
    case UPDATE_SEQUENCE = "UPDATE_SEQUENCE"
    case UPLOAD_FILES = "UPLOAD_FILES"
    case GET_REASON_LIST = "GET_REASON_LIST"
    case ADD_NOTE = "ADD_NOTE"
    case UPDATE_ORDER_ITEM_STATUS = "UPDATE_ORDER_ITEM_STATUS"
    case UPDATE_BARCODE_ORDER_ITEM = "UPDATE_BARCODE_ORDER_ITEM"
    case ADD_NEW_ORDER_ITEM = "ADD_NEW_ORDER_ITEM"
    case UPDATE_TOKEN_FCM = "UPDATE_TOKEN_FCM"
    case CREATE_NEW_MESSAGE = "CREATE_NEW_MESSAGE"
    case GET_COUNT_MESSAGE_NUMBER = "GET_COUNT_MESSAGE_NUMBER"
    case GET_ROUTE_DETAIL = "GET_ROUTE_DETAIL"
    case READ_MESSAGE = "READ_MESSAGE"
    case CHECK_TOKEN = "CHECK_TOKEN"
    case CHANGE_PASSWORD = "CHANGE_PASSWORD"
    case GET_LIST_NOTIFICATIONS = "GET_LIST_NOTIFICATIONS"
    case RESET_PASSWORD_URL = "RESET_PASSWORD_URL"
    case GET_ALERT_DETAIL = "GET_ALERT_DETAIL"
    case RESOLVE_ALERT = "RESOLVE_ALERT"
    case GET_USERID_BY_TOKEN = "GET_USERID_BY_TOKEN"
    case GET_USER_PROFILE = "GET_USER_PROFILE"
    case UPDATE_USER_PROFILE = "UPDATE_USER_PROFILE"
    case UPDATE_DRIVER_LOCATION = "UPDATE_DRIVER_LOCATION"
    case GET_DRIVER_BY_COORDINATOR = "GET_DRIVER_BY_COORDINATOR"
    case ASSIGN_ORDER = "ASSIGN_ORDER"
    
    var URL:String  {
        return E(DMSAppConfiguration.pathUrls[self.rawValue])
     }
}


class RESTConstants: NSObject {
    //MARK: RESTRequest Header Keys
    static let requestHeaderKey                   = "Header"
    static let requestAuthorizationKey            = "Authorization"
    static let requestContentTypeKey              = "Content-Type"
    static let requestAcceptKey                   = "Accept"
    //    static let headers                            = ["Content-Type" : "application/json"]
    static let headers                            = ["Content-Type" : "application/x-www-form-urlencoded"]
    static let frefixToken                        = "Bearer "
    static let statusCodeSuccess: Int             = 0
  
    static let serverFile = "https://apigw.seldatdirect.com/dev/dms/99cents/api/backend-api/v1/file/"
    
    static let BASE_URL = "BASE_URL"
    static let BASE_URL_DEV = "BASE_URL_DEV"
    static let BASE_URL_PRODUCT = "BASE_URL_PRODUCT"
    static let BASE_URL_GOOGLE_MAP = "BASE_URL_GOOGLE_MAP"
    static let LOGIN = "LOGIN"
    static let FORGET_PASSWORD = "FORGET_PASSWORD"
    static let LOGOUT = "LOGOUT"
    static let GET_ORDERS = "GET_ORDERS"
    static let GET_ORDER_BY_DATE = "GET_ORDER_BY_DATE"
    static let GET_ROUTES_BY_DATE = "GET_ROUTES_BY_DATE"
    static let GET_PACKAGES_IN_ROUTE = "GET_PACKAGES_IN_ROUTE"
    static let GET_ORDER_DETAIL = "GET_ORDER_DETAIL"
    static let UPDATE_ORDER_STATUS = "UPDATE_ORDER_STATUS"
    static let UPLOAD_SIGNATURE = "UPLOAD_SIGNATURE"
    static let UPDATE_SEQUENCE = "UPDATE_SEQUENCE"
    static let UPLOAD_FILES = "UPLOAD_FILES"
    static let GET_REASON_LIST = "GET_REASON_LIST"
    static let ADD_NOTE = "ADD_NOTE"
    static let UPDATE_ORDER_ITEM_STATUS = "UPDATE_ORDER_ITEM_STATUS"
    static let UPDATE_BARCODE_ORDER_ITEM = "UPDATE_BARCODE_ORDER_ITEM"
    static let ADD_NEW_ORDER_ITEM = "ADD_NEW_ORDER_ITEM"
    static let UPDATE_TOKEN_FCM = "UPDATE_TOKEN_FCM"
    static let CREATE_NEW_MESSAGE = "CREATE_NEW_MESSAGE"
    static let GET_COUNT_MESSAGE_NUMBER = "GET_COUNT_MESSAGE_NUMBER"
    static let GET_LIST_NOTIFICATIONS = "GET_LIST_NOTIFICATIONS"
    static let GET_ROUTE_DETAIL = "GET_ROUTE_DETAIL"
    static let READ_MESSAGE = "READ_MESSAGE"
    static let CHECK_TOKEN = "CHECK_TOKEN"
    static let CHANGE_PASSWORD = "CHANGE_PASSWORD"
    static let RESET_PASSWORD_URL = "RESET_PASSWORD_URL"
    static let GET_ALERT_DETAIL = "GET_ALERT_DETAIL"
    static let RESOLVE_ALERT = "RESOLVE_ALERT"
    
    // Profile
    static let GET_USERID_BY_TOKEN = "GET_USERID_BY_TOKEN"
    static let GET_USER_PROFILE = "GET_USER_PROFILE"
    static let UPDATE_USER_PROFILE = "UPDATE_USER_PROFILE"

    
    // Tracking
    static let UPDATE_DRIVER_LOCATION = "UPDATE_DRIVER_LOCATION"
    
    //MARK: Keys for parser
    static let successKeyFromResponseData         = "status"
    static let messageKeyFromResponseData         = "error"
    static let defaultMessageKeyFromResponseData  = "unknow_error"
    
    static let configs: [String: String] = {
        if let bundle = Bundle.main.url(forResource: "MainConfigs", withExtension: "plist"),
            let dic = NSDictionary(contentsOf: bundle) {
            return dic as! [String: String]
        }
        return [String: String]()
    }()
    
    static let ServicesConfigs: [String : String] = {
        if let bundle = Bundle.main.url(forResource: "ServicesConfigs", withExtension: "plist"),
            let dic = NSDictionary(contentsOf: bundle) {
            return dic as! [String: String]
        }
        return [String: String]()
    }()
    
    class func getBASEURL() -> String? {
        
        if let debugServer = Debug.shared.useServer {
            return debugServer;
        }
        
        let type = SDBuildConf.buildScheme
        switch type {
        case .debug,
             .adhoc:
            return DMSAppConfiguration.baseUrl_Dev

        case .release:
            return DMSAppConfiguration.baseUrl_Product
        }
    }
}
