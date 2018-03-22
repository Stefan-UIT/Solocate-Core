//
//  OrderItem.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderItem: NSObject, Mappable {
  var id = -1
  var sku = "-"
  var desc = "-"
  var vol = "-"
  var weight = "-"
  var qty = 0
  var barcode = "-"
  var statusName = "-"
  var statusCode = ""
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    sku <- map["sku"]
    desc <- map["desc"]
    vol <- map["vol"]
    weight <- map["weight"]
    qty <- map["qty"]
    barcode <- map["barcode"]
    statusName <- map["status_name"]
    statusCode <- map["status_code"]
    id <- map["id"]
    
  }
  
  

}
