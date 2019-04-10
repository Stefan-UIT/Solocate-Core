	//
//  RESTConstants.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

typealias JSONData = [String: Any]
typealias OnCompletion = (_ successful: Bool, _ data: Any?) -> Void
    

enum PATH_REQUEST_URL: String{
    case LOGIN = "auth/v1/login"
    case FORGET_PASSWORD = "auth/v1/user/forgot-password"
    case LOGOUT = "auth/v1/user/logout"
    case GET_ORDERS = "backend-api/driver/v1/orders"
    case GET_ORDER_BY_DATE = "backend-api/v1/routes/get-routes-by-date"
    case GET_ORDER_BY_COORDINATOR = "backend-api/v1/orders/all-order-by-coordinator?date=%@"
    case GET_ROUTES_BY_DATE = "transaction/v1/mobile/routes/by-driver?start_time=%@&amp;end_time=%@"
    case GET_ROUTE_BY_COORDINATOR = "backend-api/v1/routes/all-route-by-coordinator?date=%@"
    case GET_PACKAGES_IN_ROUTE = "backend-api/v1/routes/get-packages-by-driver?id=%@&amp;date=%@"
    case GET_ORDER_DETAIL = "transaction/v1/orders/%@"
    case UPDATE_ORDER = "transaction/v1/mobile/orders/%@/%@"
    case UPDATE_SEQUENCE = "backend-api/v1/routes/update-sequence"
    case UPLOAD_FILES = "transaction/v1/orders/%@/%@"
    case GET_REASON_LIST = "masterdata/v1/reason-fails/list-active"
    case ADD_NOTE = "backend-api/v1/orders/%@/notes"
    case UPDATE_ORDER_ITEM_STATUS = "backend-api/v1/orders/update-status-items/%@/%@"
    case UPDATE_BARCODE_ORDER_ITEM = "backend-api/v1/orders/update-barcode-items/%@"
    case ADD_NEW_ORDER_ITEM = "backend-api/v1/mobile/orders/%@/items"
    case UPDATE_TOKEN_FCM = "notification/notify-tokens/update"
    case CREATE_NEW_MESSAGE = "backend-api/v1/messages"
    case GET_COUNT_MESSAGE_NUMBER = "backend-api/v1/messages/count-message?type_message=%@&amp;route_id=%@"
    case GET_ROUTE_DETAIL = "transaction/v1/mobile/routes/%@"
    case CHECK_TOKEN = "authentication/users/token"
    case CHANGE_PASSWORD = "auth/v1/user/change-password"
    case GET_LIST_NOTIFICATIONS = "backend-api/v1/messages/list-message?page=1&amp;limit=100&amp;route_id=%@"
    case RESET_PASSWORD_URL = "#/reset-passwor"
    case GET_ALERT_DETAIL = "masterdata/v1/mobile/alerts/%@"
    case RESOLVE_ALERT = "masterdata/v1/mobile/alerts/resolve/%@"
    case USER_PROFILE = "auth/v1/user/profile"
    case UPDATE_DRIVER_LOCATION = "gps-tracking/api/gps-drivers"
    case GET_DRIVER_BY_COORDINATOR = "backend-api/v1/users/get-driver-by-coordinator"
    case ASSIGN_ORDER = "backend-api/v1/orders/assign-order"
    case GET_LIST_TASKS = "backend-api/v1/mobile/tasks/driver-task?from_delivery_date=%@&amp;to_delivery_date=%@"
    case GET_TASK_DETAIL = "backend-api/v1/mobile/tasks/%@"
    case UPDATE_STATUS_TASK = "backend-api/v1/tasks/%@/%@"
    case GET_DRIVING_RULE = "masterdata/v1/variables/get?key=driving_rule"
    case START_ROUTE = "transaction/v1/routes/process/%@/IP"
    case GET_LIST_STATUS = "masterdata/v1/order-statuses/list-active"
    case GET_ALL_ROUTE_INPROGESS = "transaction/v1/routes/in-progress"
    case GET_LIST_ALERT = "masterdata/v1/mobile/alerts/driver-alerts"
    case DASHBOARD = "transaction/v1/mobile/dashboard/by-driver?start_time=%@&amp;end_time=%@"

    
    var URL:String  {
        return rawValue
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
    
    class func getBASEURL() -> String? {
        return SDBuildConf.serverUrlString()
    }
    
    class func SERVER_TRACKING_URL() -> String {
        var serverURL = ""
        let type = SDBuildConf.serverEnvironment
        switch type {
        case .development:
            serverURL = "http://dms-customization.dev.seldatdirect.com/"
        case .staging,
             .testing:
            serverURL = "http://dms-customization.staging.seldatdirect.com/"
        case .production:
            serverURL = "http://dms-customization.live.seldatdirect.com/"
        }
        return serverURL
    }
}
