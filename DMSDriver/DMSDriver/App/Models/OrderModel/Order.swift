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
    case pickupStatus = "PU"
    
    var statusName: String {
        switch self {
        case .newStatus:
            return "New".localized
        case .inProcessStatus:
            return "Started".localized
        case .pickupStatus:
            return "Picked Up"
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
    var lattd:String?
    var lngtd:String?
    var name:String?
    var phone:String?
    var start_time:String?
    var end_time:String?
    var ctt_name:String?
    var ctt_phone:String?
    var seq = 1
    var loc_name:String?
    
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
        name <- map["ctt_name"]
        phone <- map["ctt_phone"]
        start_time <- map["start_time"]
        end_time <- map["end_time"]
        ctt_name <- map["ctt_name"]
        ctt_phone <- map["ctt_phone"]
        seq <- map["seq"]
        loc_name <- map["loc_name"]
    }
}


//MARK: -Order
class Order: BaseModel {

    class Detail: BaseModel {
        
        enum DetailStatus {
            case NotLoad
            case Loaded
            case Unload
            
            var name:String{
                get{
                    switch self {
                    case .NotLoad:
                        return "Not Load".localized
                    case .Loaded:
                        return "Loaded".localized
                    case .Unload:
                        return "Unloaded".localized
                    }
                }
            }
        }
        
        struct Package:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["cd"]
            }
        }
        
        struct Unit:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["cd"]
            }
        }
        
        var order_id:Int?
        var package_id:Int?
        var qty:Double?
        var remain_qty:Double?
        var package:Package?
        var unit:Unit?
        var barCode:String?
        var packageRefId:Int?
        var status:DetailStatus = .NotLoad
        
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            order_id <- map["order_id"]
            package_id <- map["package_id"]
            qty <- map["qty"]
            remain_qty <- map["remain_qty"]
            package <- map["package"]
            barCode <- map["barcode"]
            packageRefId <- map["pkg_ref_id"]
            unit <- map["unit"]
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
    //var url:UrlFileMoldel?
    var files:[AttachFileModel]?

    var isSelect = false
    var directionRoute:[DirectionRoute]? // use for save DirectionRoute
    var route:Route?
    
    var status:Status? {
        didSet {
            updateStatusDetailOrder()
        }
    }
    
    lazy var totalEstDuration:Int = {
        var total = 0
        directionRoute?.forEach({ (directionRoute) in
            directionRoute.legs.forEach({ (leg) in
                total += Int(leg.duration.value)
            })
        })
        
        return total
    }()
    
    lazy var totalEstDistance:Double = {
        var total:Double = 0
        directionRoute?.forEach({ (directionRoute) in
            directionRoute.legs.forEach({ (leg) in
                total += leg.distance.value
            })
        })
        
        return Double(total)
    }()

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
        files <- map["files"]
        urgent_type_id <- map["urgent_type_id"]
        status <- map["status"]
        driver_id <- map["driver_id"]
        route <- map["route"]
        
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
        
       updateStatusDetailOrder()
    }
    
    func updateStatusDetailOrder()  {
        for item in details ?? [] {
            if statusOrder == .newStatus ||
                statusOrder == .inProcessStatus {
                item.status = .NotLoad
                
            }else if (statusOrder == .pickupStatus) {
                item.status = .Loaded
            }else if (statusOrder == .deliveryStatus) {
                item.status = .Unload

            }
        }
    }
    
    func getChunkedListLocation() -> [[CLLocationCoordinate2D]] {
        let currentLocation = LocationManager.shared.currentLocation?.coordinate
        var listLocation:[CLLocationCoordinate2D] = (currentLocation != nil) ? [currentLocation!] : []
        listLocation.append(locations)
        
        var listChunked = listLocation.chunked(by: 22)
        if listChunked.count > 1 {
            for i in 1..<listChunked.count{
                if let first = listChunked[i].first {
                    listChunked[i - 1].append(first)
                }
            }
        }
        
        return listChunked
    }
    
    var signature:AttachFileModel?{
        get{
            for i in 0..<(files?.count ?? 0){
                if files?[i].typeFile == "SIG"{
                    return files?[i]
                }
            }
            
            return nil
        }
    }
    
    var pictures:[AttachFileModel]?{
        get{
            
            var arr:[AttachFileModel]?
            for i in 0..<(files?.count ?? 0){
                if files?[i].typeFile != "SIG"{
                    if arr == nil {
                        arr = []
                    }
                    if let file = files?[i] {
                        arr?.append(file)
                    }
                }
            }
            
            return arr
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
            return CLLocationCoordinate2D(latitude:from?.lattd?.doubleValue ?? 0, longitude: from?.lngtd?.doubleValue ?? 0)
        }
    }
    
    
    var locationTo:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:to?.lattd?.doubleValue ?? 0, longitude: to?.lngtd?.doubleValue ?? 0)
        }
    }
    
    var locations:[CLLocationCoordinate2D] {
        get {
             var arr:[CLLocationCoordinate2D] = []
             if let fromlattd = from?.lattd?.doubleValue ,
                let fromLngtd = from?.lngtd?.doubleValue {
                arr.append(CLLocationCoordinate2D(latitude:fromlattd, longitude: fromLngtd))
             }
            
            if let tolattd = to?.lattd?.doubleValue ,
                let toLngtd = to?.lngtd?.doubleValue {
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
            case .pickupStatus:
                return AppColor.pickedUpStatus;
            case .deliveryStatus:
                return AppColor.deliveryStatus;
            case .cancelStatus,
                 .cancelFinishStatus:
                return AppColor.redColor;
            }
        }
    }
    
    func isRequireSign() -> Bool  {
        return false  //sig_req == 1 && signature == nil
    }
    
    func isRequireImage() -> Bool  {
        return false //pod_req == 1 && pictures?.count ?? 0 <= 0
    }
    
    func validUpdateStatusOrder() -> Bool {
        var valid = true
        for item in details ?? []  {
            if statusOrder == StatusOrder.inProcessStatus {
                if item.status != .Loaded {
                    valid = false
                    break
                }
            }else if statusOrder == StatusOrder.pickupStatus {
                if item.status != .Unload {
                    valid = false
                    break
                }
            }
        }
        
        return valid
    }
    
    /*
    func cloneObject() -> Order? {
        let json = getJSONString()
        let obj = Order(JSON: json)
        return obj
    }
     */
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


