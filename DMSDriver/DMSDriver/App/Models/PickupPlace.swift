//
//  PickupPlace.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class PickupPlace: NSObject, Mappable {
  var contactName = ""
  var contactEmail = ""
  var contactPhone = ""
  var shopID = -1
  var shopName = ""
  var lat: Double = 0.0
  var lng: Double = 0.0
  
  convenience required init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    contactName   <- map["pkup_ctt_name"]
    contactEmail  <- map["pkup_ctt_email"]
    contactPhone  <- map["pkup_ctt_phone"]
    shopID        <- map["shop_id"]
    shopName      <- map["shop"]
    lat           <- map["lat"]
    lng           <- map["long"]
  }
}
