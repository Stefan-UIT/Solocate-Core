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

enum OrderType:Int {
    case delivery = 1
    case pickup
    case deliveryAndPickup
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
    var bcd = ""
    
    var seq = -1
    var pallets = -1
    var cases = -1
    var shop:String = ""
    var startTime = ""
    var endTime = ""
    var reason_msg = ""
    
    var standby = 0
    var client_name:String = ""
    var custumer_name:String = ""
    var instructions:String = ""
    var details:String = ""
    var urgent = 0
    var surfaces:String = ""
    var thirdCourier:String = ""

    var certificateNumber = 0
    var coordinationPhone = ""
    var basePrice:Double = 0
    var receiveName:String = ""
    var secoundReceiveName:String = ""
    var totalPerCustomer:String = ""
    var fromTodayToTomorrow:String = ""
    var signedCertificate :String = ""
    var collectionCall:String = ""
    var comments = ""
    var doubleType = 0
    var packages = 0
    var cartons = 0
    var toAddressName = ""
    var toAddressPhone = ""
    var receiverPhone = ""
    var toAddressEmail = ""
    var toAddressStreet = ""
    var toAddressHouseNumber = ""
    var toAddressEntrance = ""
    var toAddressFloor = ""
    var toAddressApartment = ""
    var toAddressCity = ""
    var toAddressAddr = ""
    var toAddressFullAddress = ""
    var orderTypeId = 0
    var orderTypeName = ""
    var order_status = ""
    var created_at = ""
    var pod = 0
    var sign = -1
    var to_loc_id = -1
    var order_type_name = ""
    var order_type_name_hb = ""
    var urgent_type_name_en = ""
    var urgent_type_name_hb = ""
    var urgent_type_id = -1
    var from_loc_id = -1
    var location_name = ""
    var location_full_addr = ""
    var from_address_full_addr = ""
    var from_address_lattd = ""
    var from_address_lngtd = ""
    var to_address_lattd = ""
    var to_address_lngtd = ""
    var truck_name = ""

    //temp
    var driverId = -1
    var driverName = -1
    

    var colorUrgent:UIColor{
        get{
            switch urgent_type_id {
            case 2:
                return AppColor.medium
            case 3:
                return AppColor.high
            default:
                return AppColor.normal
            }
        }
    }

    
    
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
        lat               <- map["lattd"]
        lng               <- map["lngtd"]
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
        
        standby <- map["standby"]
        client_name <- map["client_name"]
        custumer_name <- map["custumer_name"]
        instructions <- map["instructions"]
        details <- map["details"]
        urgent <- map["urgent"]
        surfaces <- map["surfaces"]
        certificateNumber <- map["cert_num"]
        coordinationPhone <- map["coord_phone"]
        basePrice <- map["base_price"]
        receiveName <- map["rcvr_name"]
        secoundReceiveName <- map["second_rcvr_name"]
        totalPerCustomer <- map["total_per_customer"]
        fromTodayToTomorrow <- map["from_today_to_tomorrow"]
        signedCertificate <- map["signed_cert"]
        collectionCall <- map["collect_call"]
        comments <-  map["cmnt"]
        doubleType <- map["double_type"]
        packages <- map["packages"]
        cartons <- map["cartons"]
        toAddressName <- map["to_address_name"]
        toAddressPhone <- map["to_address_phone"]
        toAddressEmail <- map["to_address_email"]
        toAddressStreet <- map["to_address_street"]
        toAddressHouseNumber <- map["to_address_house_num"]
        toAddressEntrance <- map["to_address_entrance"]
        toAddressFloor <- map["to_address_floor"]
        toAddressApartment <- map["to_address_apartment"]
        toAddressCity <- map["to_address_city"]
        toAddressAddr <- map["to_address_addr"]
        toAddressFullAddress <- map["to_address_full_addr"]
        orderTypeId <- map["order_type_id"]
        orderTypeName <- map["order_type_name"]
        order_status <- map["order_status"]
        created_at <- map["created_at"]
        bcd <- map["bcd"]
        pod <- map["pod"]
        to_loc_id <- map["to_loc_id"]
        order_type_name <- map["order_type_name"]
        order_type_name_hb <- map["order_type_name_hb"]
        urgent_type_name_en <- map["urgent_type_name_en"]
        urgent_type_name_hb <- map["urgent_type_name_hb"]
        urgent_type_id <- map["urgent_type_id"]
        sign <- map["sign"]
        thirdCourier <- map["3rd_courier"]
        from_address_full_addr <- map["from_address_full_addr"]
        from_address_lattd <- map["from_address_lattd"]
        from_address_lngtd <- map["from_address_lngtd"]
        to_address_lattd <- map["to_address_lattd"]
        to_address_lngtd <- map["to_address_lngtd"]
        truck_name <- map["truck_name"]
        receiverPhone <- map["rcvr_phone"]
  }
    
    func isRequireSign() -> Bool  {
        return sign == 1
    }
    
    func isRequireImage() -> Bool  {
        return pod == 1
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
    
    class UrlFileMoldel: BaseModel {
        var sig: AttachFileModel?
        var doc: [AttachFileModel]?
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            sig <- map["sig"]
            doc <- map["doc"]
        }
    }
    
    class ToAddress: BaseModel {
        var id: Int?
        var order_id: Int?
        var name:String?
        var street:String?
        var phone:String?
        var house_num:String?
        var entrance:String?
        var floor:String?
        var apartment:String?
        var city:String?
        var lattd:String?
        var lngtd:String?
        var addr:String?
        var full_addr:String?

        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            order_id <- map["order_id"]
            name <- map["name"]
            street <- map["street"]
            phone <- map["phone"]
            house_num <- map["house_num"]
            entrance <- map["entrance"]
            floor <- map["floor"]
            apartment <- map["apartment"]
            city <- map["city"]
            lattd <- map["lattd"]
            lngtd <- map["lngtd"]
            addr <- map["addr"]
            full_addr <- map["full_addr"]
        }
    }
    
    class Order_Detail: BaseModel {
        var id: Int?
        var order_id: Int?
        var double_type:Int = 0
        var packages:Int = 0
        var cartons:Int = 0
        var ac:Int = 0
        var created_at:String?
        var updated_at:String?
        
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            order_id <- map["order_id"]
            double_type <- map["double_type"]
            packages <- map["packages"]
            cartons <- map["cartons"]
            ac <- map["ac"]
            created_at <- map["created_at"]
            updated_at <- map["updated_at"]
        }
    }
    
    
  var serviceTime = -1
  var deliveryContactName = ""
  var deliveryContactPhone = ""
  var deliveryCity = ""
  var deliveryState = ""
  var descriptionNote = ""
  var descriptionNoteExt = ""
  var notes = [Note]()
  var items = [OrderItem]()
  var pictures = [Picture]()
  var url:UrlFileMoldel?
  var reason:ReasonOrderCC?
    
  var toAddress:ToAddress?
  var order_detail:Order_Detail?
    
    
  
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
    
    url <- map["url"]
    reason <- map["reason"]
    toAddress <- map["to_address"]
    order_detail <- map["order_detail"]
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


