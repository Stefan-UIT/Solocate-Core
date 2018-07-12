//
//  Order.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

enum StatusOrder: String {
    case newStatus = "OP"
    case inProcessStatus = "IP"
    case deliveryStatus = "DV"
    case cancelStatus = "CC"
}

class Order: BaseModel {
  var id = -1
  var deliveryZip = ""
  var totalVolume = ""
  var totalWeight = ""
  var floorSpace = ""
  var shopID = -1
  var locationID = -1
  var storeName = ""
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
  var routeId = -1
    
  var seq = -1
  var pallets = -1
  var cases = -1
  var shop:String = ""
  var startTime = ""
  var endTime = ""
  var reason_msg = ""
  var status:StatusOrder{
     get{
        return StatusOrder(rawValue: statusCode) ?? .newStatus
     }
  }

    
    var location:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lng.doubleValue)
        }
    }
    
  var colorStatus:UIColor {
    get{
        switch status {
        case .newStatus:
            return AppColor.newStatus;
        case .inProcessStatus:
            return AppColor.inProcessStatus;
        case .deliveryStatus:
            return AppColor.deliveryStatus;
        case .cancelStatus:
            return AppColor.redColor;
        }
     }
    }


  convenience required init?(map: Map) {
    self.init()
  }
  
    override func mapping(map: Map) {
        id                <- map["order_id"]
        deliveryZip       <- map["dlvy_zip"]
        totalVolume       <- map["tot_vol"]
        totalWeight       <- map["tot_weight"]
        floorSpace        <- map["floor_space"]
        shopID            <- map["shop_id"]
        locationID            <- map["loc_id"]
        storeName          <- map["store_name"]
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
        routeId           <- map["route_id"]
        
        seq  <- map["seq"]
        pallets  <- map["pallets"]
        cases  <- map["cases"]
        shop  <- map["shop"]
        startTime  <- map["dlvy_start_time"]
        endTime  <- map["dlvy_end_time"]
        reason_msg <- map["reason_msg"]

  }
    
}

class ReasonOrderCC: Reason {
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["reason_name"]
        reasonDescription <- map["reason_desc"]
    }
}


class OrderDetail: Order {
  var serviceTime = -1
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
  var signFile:AttachFileModel?
  var reason:ReasonOrderCC?
  
  override init() {
    super.init()
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    id <- map["id"]
    deliveryContactName <- map["ctt_name"]
    if deliveryContactName.isEmpty {
        deliveryContactName <- map["dlvy_ctt_name"]
    }
    deliveryContactPhone <- map["ctt_phone"]
    if deliveryContactPhone.isEmpty {
        deliveryContactPhone <- map["dlvy_ctt_phone"]
    }
    timeWindowName <- map["time_window_text"]
    deliveryAdd <- map["full_addr"]
    if deliveryAdd.isEmpty {
        deliveryAdd <- map["dlvy_full_addr"]
    }
    deliveryCity <- map["dlvy_city"]
    deliveryState <- map["dlvy_state"]
    descriptionNote <- map["note"]
    descriptionNoteExt <- map["note_ext"]
    sign <- map["sig"]
    notes <- map["notes"]
    pictures <- map["url"]
    items <- map["details"]
    
    deliveryDate <- map["dlvy_date"];
    serviceTime <- map["service_time"]
    
    signFile <- map["url"]
    reason <- map["reason"]
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


