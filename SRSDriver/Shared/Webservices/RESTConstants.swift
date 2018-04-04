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
  
  static let BASE_URL = "BASE_URL"
  static let LOGIN = "LOGIN"
  static let GET_ORDERS = "GET_ORDERS"
  static let GET_ORDER_BY_DATE = "GET_ORDER_BY_DATE"
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
  static let UPDATE_NOTIFICATION_TOKEN = "UPDATE_NOTIFICATION_TOKEN"
  static let CREATE_NEW_MESSAGE = "CREATE_NEW_MESSAGE"
  static let GET_COUNT_MESSAGE_NUMBER = "GET_COUNT_MESSAGE_NUMBER"
  static let GET_LIST_NOTIFICATIONS = "GET_LIST_NOTIFICATIONS"
  static let GET_ROUTE_DETAIL = "GET_ROUTE_DETAIL"
  
  //MARK: Keys for parser
  static let successKeyFromResponseData         = "status"
  static let messageKeyFromResponseData         = "error"
  static let defaultMessageKeyFromResponseData  = "unknow_error"
  
  static let configs: [String: String] = {
    #if MASOF
      let configName = "configs_masof"
    #elseif MALEE
      let configName = "configs_malee"
    #else
      let configName = "configs_masof"
    #endif
    
    
    if let bundle = Bundle.main.url(forResource: configName, withExtension: "plist"),
      let dic = NSDictionary(contentsOf: bundle) {
      return dic as! [String: String]
    }
    return [String: String]()
  }()
  
  
}
