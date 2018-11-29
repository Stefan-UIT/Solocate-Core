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
    
    var statusName: String {
        switch self {
        case .newStatus:
            return "New".localized
        case .inProcessStatus:
            return "In Progress".localized
        case .deliveryStatus:
            return "Finished".localized
        case .cancelStatus:
            return "Cancelled".localized
        }
    }
}

enum OrderType:Int {
    case delivery = 1
    case pickup
    case deliveryAndPickup
}

class Address: BaseModel {
    var address:String?
    var lattd:Double?
    var lngtd:Double?
    var name:String?
    var phone:String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        address <- map["address"]
        lattd <- map["lattd"]
        lngtd <- map["lngtd"]
        name <- map["name"]
        phone <- map["phone"]
    }
}


//MARK: -Order
class Order: BaseModel {

    class Detail: BaseModel {
        var order_id:Int?
        var nature_id:Int?
        var vol:Double?
        var nature:Nature?
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            order_id <- map["order_id"]
            nature_id <- map["nature_id"]
            vol <- map["vol"]
            nature <- map["nature"]
        }
    }

    class Nature: BaseModel {
        var id:Int?
        var name:String?
        var cd:String?
        var hazardous_mtrl:String?
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            cd <- map["cd"]
            hazardous_mtrl <- map["hazardous_mtrl"]
        }
    }

    var id = -1
    var from:Address?
    var to:Address?
    var route_id:Int = 0
    var status_id:Int?
    var seq:Int = 0
    var pod_req:Int?
    var sig_req:Int?
    var note:String?
    var details:[Detail]?

    var startTime = ""
    var endTime = ""
    var urgent_type_name_hb = ""
    var urgent_type_name_en = ""
    var statusName = ""
    var statusCode = ""
    var driver_id:Int = 0
    var driver_name = ""
    var client_name = ""
    var order_type_name_hb = ""
    var order_type_name = ""
    var reason_msg:String?
    var custumer_name = ""
    var doubleType = -1
    var orderReference = ""
    var packages = 0
    var cartons = 0
    var truck_name = ""
    var collectionCall = ""
    var coordinationPhone = ""
    var standby = ""
    var receiveName = ""
    var apartment = ""
    var floor = ""
    var entrance = ""
    var full_addr = ""
    var receiverPhone = ""
    
    var urgent_type_id:Int = 0
    var url:UrlFileMoldel?
    var isSelect = false
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id    <- map["id"]
        route_id <- map["route_id"]
        status_id <- map["status_id"]
        seq <- map["seq"]
        pod_req <- map["pod_req"]
        sig_req <- map["sig_req"]
        note <- map["note"]
        details <- map["details"]
        url <- map["url"]
        urgent_type_id <- map["urgent_type_id"]
        
        if  let dataFrom = map["from"].currentValue as? String{
            from    = Address(JSON: dataFrom.parseToJSON() ?? [:])
        }else{
            from    <- map["from"]
        }
        
        if  let dataTo = map["to"].currentValue as? String{
            to    = Address(JSON: dataTo.parseToJSON() ?? [:])
        }else{
            to    <- map["to"]
        }
    }
    

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
            var longitude = 0.0
            var latitude = 0.0
            /*
            if lat.length > 0 {
                latitude = lat.doubleValue
            }else if to_address_lattd.length > 0{
                latitude = to_address_lattd.doubleValue
            }else {
                latitude = from_address_lattd.doubleValue
            }
            
            if lng.length > 0 {
                longitude = lng.doubleValue
            }else if to_address_lngtd.length > 0{
                longitude = to_address_lngtd.doubleValue
            }else {
                longitude = from_address_lngtd.doubleValue
            }

             */
            return CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
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
    
    func isRequireSign() -> Bool  {
        return sig_req == 1
    }
    
    func isRequireImage() -> Bool  {
        return pod_req == 1
    }
    
    func convertToOrderDetail() -> OrderDetail {
        let orderDetail = OrderDetail()
        orderDetail.id  = id
        orderDetail.statusName   =  statusName
        orderDetail.seq = seq
        orderDetail.from = from
        orderDetail.to = to
        orderDetail.details = details
        orderDetail.status_id = status_id
        return orderDetail
    }
}

//MARK: -UrlFileMoldel
class UrlFileMoldel: BaseModel {
    var id = -1
    var sig: AttachFileModel?
    var doc: [AttachFileModel]?
    
    override init() {
        super.init()
        doc = []

    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        sig <- map["sig"]
        doc <- map["doc"]
    }
}


//MARK: -ToAddress
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

//MARK: -Order_Detail
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



//MARK: -OrderDetail
class OrderDetail: Order {
    
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
    var reason:Reason?
    var toAddress:ToAddress?
    var order_detail:Order_Detail?
    var route_detail:Route?
    
  
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
        deliveryCity <- map["dlvy_city"]
        deliveryState <- map["dlvy_state"]
        descriptionNote <- map["note"]
        descriptionNoteExt <- map["note_ext"]
        notes <- map["notes"]
        pictures <- map["url"]
        items <- map["details"]
        serviceTime <- map["service_time"]
    
        reason <- map["reason"]
        toAddress <- map["to_address"]
        order_detail <- map["order_detail"]
        route_detail <- map["route_detail"]
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


