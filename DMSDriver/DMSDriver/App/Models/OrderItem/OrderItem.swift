//
//  OrderItem.swift
//  SRSDriver
//
//  Created by Nguyen Phu on 3/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderItem: BaseModel {
  var id = -1
  var name = ""
  var sku = ""
  var desc = ""
  var vol = ""
  var weight = ""
  var qty = 0
  var barcode = ""
  var statusName = ""
  var statusCode = ""
  var total = -1
  var bearconId = "" // Add by Hoang Trinh for Masof
  
  required convenience init?(map: Map) {
    self.init()
  }
  
    override func mapping(map: Map) {
    
    name <- map["name"]
    sku <- map["sku"]
    desc <- map["desc"]
    vol <- map["vol"]
    weight <- map["weight"]
    qty <- map["qty"]
    barcode <- map["barcode"]
    statusName <- map["status_name"]
    statusCode <- map["status_code"]
    id <- map["id"]
    total <- map["total"]
    bearconId <- map["beacon_id"] // Add by Hoang Trinh for Masof
  }
  
}
