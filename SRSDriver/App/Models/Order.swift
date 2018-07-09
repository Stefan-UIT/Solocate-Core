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
/*
 "id": 63,
 "shop_id": 45,
 "store_name": "L.V. - NELLIS",
 "addr": "115/24 Phan Đăng Lưu",
 "full_addr": "115/24 Phan Đăng Lưu, Phường 7, Phú Nhuận, Hồ Chí Minh, Vietnam",
 "city": "Hồ Chí Minh",
 "state": null,
 "zip": "70000",
 "ctt_name": "Tri Le",
 "ctt_phone": "0978756054",
 "ctt_phone2": null,
 "ctt_email": "ldtri0209@gmail.com",
 "lat": "10.8032150",
 "long": "106.6855360",
 "note": "abc",
 "dlvy_start_time": "11:39",
 "dlvy_end_time": "12:09",
 "order_sts": "DV",
 "route_id": 51,
 "order_ref": "234",
 "sig": null,
 "seq": 2,
 "service_time": 30,
 "order_type_name": "Delivery",
 "order_type_id": 1,
 "reason_msg": null,
 "loc_id": 1,
 "dlvy_date": "06/29/2018",
 "send_email": 0,
 "send_sms": 0,
 "pallets": 12,
 "cases": 33,
 "driver_name": "mach nguyen",
 "order_status_name": "Finished",
 "created_at": "06/29/2018",
 "dlvd_dt": "06/29/2018 03:42",
 "dlvd_dt_date": "06/29/2018",
 "dlvd_dt_time": "03:42",
 "url": {
 "link": "https://apigw.seldatdirect.com/dev/dms/99cents/api/backend-api/v1/file/",
 "name": null
 }
 }
 */

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


