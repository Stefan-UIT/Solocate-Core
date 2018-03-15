//
//  Order.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class Order: NSObject, Mappable {
  var id = -1
  var deliveryZip = ""
  var totalVolume = ""
  var totalWeight = ""
  var floorSpace = ""
  var shopID = -1
  var shopName = ""
  var sequence = -1
  var pickupContactName = ""
  var pickupContactPhone = ""
  var pickupContactEmail  = ""
  var lat = ""
  var lng = ""
  var statusCode = ""
  var statusName = ""
  var orderReference = ""
  var deliveryDate = ""
  var deliveryAdd = ""
  var timeWindowName = ""
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id                <- map["route_id"]
    deliveryZip       <- map["dlvy_zip"]
    totalVolume       <- map["tot_vol"]
    totalWeight       <- map["tot_weight"]
    floorSpace        <- map["floor_space"]
    shopID            <- map["shop_id"]
    shopName          <- map["shop"]
    sequence          <- map["seq"]
    pickupContactName <- map["pkup_ctt_name"]
    
    pickupContactPhone <- map["pkup_ctt_phone"]
    pickupContactEmail <- map["pkup_ctt_email"]
    lat               <- map["lat"]
    lng               <- map["long"]
    statusCode        <- map["order_sts"]
    statusName        <- map["order_status"]
    orderReference    <- map["order_ref"]
    deliveryDate      <- map["dlvy_date"]
    deliveryAdd       <- map["delivery"]
    timeWindowName    <- map["TimeWindowName"]
  }
  
  
}


