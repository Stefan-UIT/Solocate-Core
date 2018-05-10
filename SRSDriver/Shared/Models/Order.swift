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
  var orderType = ""
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id                <- map["order_id"]
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
    statusName        <- map["order_stmainatus"]
    orderReference    <- map["order_ref"]
    deliveryDate      <- map["dlvy_date"]
    deliveryAdd       <- map["delivery"]
    timeWindowName    <- map["TimeWindowName"]
    orderType         <- map["order_type_name"]
  }
}

class OrderDetail: Order {
  var deliveryContactName = ""
  var deliveryContactPhone = ""
  var deliveryCity = ""
  var deliveryState = ""
  var descriptionNote = ""
  var descriptionNoteExt = ""
  var sign = ""
  var notes = [Note]()
  var items = [OrderItem]()
  var pictures = [Picture]()
  
  override init() {
    super.init()
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    id <- map["id"]
    deliveryContactName <- map["ctt_name"]
    deliveryContactPhone <- map["ctt_phone"]
    timeWindowName <- map["time_window_text"]
    deliveryAdd <- map["full_addr"]
    deliveryCity <- map["dlvy_city"]
    deliveryState <- map["dlvy_state"]
    descriptionNote <- map["note"]
    descriptionNoteExt <- map["note_ext"]
    sign <- map["sig"]
    notes <- map["notes"]
    pictures <- map["url"]
    items <- map["details"]
  }
}

class Picture: NSObject, Mappable {
  var link = ""
  var name = ""
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    link <- map["link"]
    name <- map["name"]
  }
  
  
}


