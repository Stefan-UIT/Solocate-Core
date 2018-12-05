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
    case cancelFinishStatus = "UF"
    
    var statusName: String {
        switch self {
        case .newStatus:
            return "New".localized
        case .inProcessStatus:
            return "In Progress".localized
        case .deliveryStatus:
            return "Finished".localized
        case .cancelStatus,
             .cancelFinishStatus:
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
    var status:Status?
    var seq:Int = 0
    var pod_req:Int?
    var sig_req:Int?
    var note:String?
    var details:[Detail]?

    var reason:Reason?
    var startTime = ""
    var endTime = ""
    var urgent_type_name_hb = ""
    var urgent_type_name_en = ""
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
        status <- map["status"]
        driver_id <- map["driver_id"]
        
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
    
    var statusCode :String{
        set{
        }
        get{
            return E(status?.code)
            
        }
    }
    
    var statusName :String{
        set{
            
        }
        get{
            return E(status?.name)
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
    
    var statusOrder:StatusOrder{
        get{
            return StatusOrder(rawValue: E(status?.code)) ?? .newStatus
        }
    }

    
    var locationFrom:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:from?.lattd ?? 0, longitude: from?.lngtd ?? 0)
        }
    }
    
    
    var locationTo:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:to?.lattd ?? 0, longitude: to?.lngtd ?? 0)
        }
    }
    
    var locations:[CLLocationCoordinate2D] {
        get {
             var arr:[CLLocationCoordinate2D] = []
             if let fromlattd = from?.lattd ,
                let fromLngtd = from?.lngtd {
                arr.append(CLLocationCoordinate2D(latitude:fromlattd, longitude: fromLngtd))
             }
            
            if let tolattd = to?.lattd ,
                let toLngtd = to?.lngtd {
                arr.append(CLLocationCoordinate2D(latitude:tolattd, longitude: toLngtd))
            }
            return arr
        }
    }
    
    var colorStatus:UIColor {
        get{
            switch statusOrder {
            case .newStatus:
                return AppColor.newStatus;
            case .inProcessStatus:
                return AppColor.inProcessStatus;
            case .deliveryStatus:
                return AppColor.deliveryStatus;
            case .cancelStatus,
                 .cancelFinishStatus:
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


