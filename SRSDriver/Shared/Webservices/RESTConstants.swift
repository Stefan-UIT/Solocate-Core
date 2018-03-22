//
//  RESTConstants.swift
//  CoreWebservice
//
//  Created by phunguyen on 3/7/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class RESTConstants: NSObject {
  //MARK: RESTRequest Header Keys
  static let requestHeaderKey                   = "Header"
  static let requestAuthorizationKey            = "Authorization"
  static let requestContentTypeKey              = "Content-Type"
  static let requestAcceptKey                   = "Accept"
  static let headers                            = ["Content-Type" : "application/json"]
//  static let headers                            = ["Content-Type" : "application/x-www-form-urlencoded"]
  static let frefixToken                        = "Bearer "
  static let statusCodeSuccess: Int             = 0
  
  
  //MARK: Keys for parser
  static let successKeyFromResponseData         = "status"
  static let messageKeyFromResponseData         = "error"
  static let defaultMessageKeyFromResponseData  = "unknow_error"

//  #if DEV
//  static let baseURL = "https://apigw.seldatdirect.com/dev/srs/api"
  static let baseURL = "https://apigw.seldatdirect.com/dev/sdms-masof/api"
//  #else
//  static let baseURL = "https://apigw.seldatdirect.com/demo/srs/api"
//  #endif
  
  static let login = "/master-service/v1/login"
  static let getOrders = "/backend-api/driver/v1/orders"
  static let getOrdersByDate = "/backend-api/v1/routes/get-routes-by-date"
  static let orderDetails = "/backend-api/v1/orders/%@"//orderID
  static let updateOrderStatus = "/backend-api/v1/orders/%@/%@"//OrderID, status
  static let uploadSignature = "/backend-api/v1/orders/add-sign/%@"// orderID
  static let updateSequence = "/backend-api/v1/routes/update-sequence"
  static let uploadFiles = "/backend-api/v1/orders/add-picture/%@" // orderID
  static let getListReason = "/backend-api/v1/reason/%@" //type 
  static let addNote = "/backend-api/v1/orders/%@/notes" //order ID
  static let updateItemStatus = "/backend-api/v1/orders/update-status-items/%@/%@" // itemID, status
  static let updateBarcodeItem = "/backend-api/v1/orders/update-barcode-items/%@" // itemID  
}
