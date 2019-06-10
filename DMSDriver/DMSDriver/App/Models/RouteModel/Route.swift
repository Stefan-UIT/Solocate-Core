//
//  Route.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleMaps

//MARK: - TRUCK
class Truck: BaseModel {
    var id:Int?
    var name:String?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}

//MARK: - Tanker
class Tanker: BaseModel {
    var id:Int?
    var name:String?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}

//MARK: - Status
class Status: BaseModel {
    var id:Int?
    var name:String?
    var code:String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        code <- map["code"]
    }
}

//MARK: - Tracking
class Tracking: BaseModel {
    var id:Int?
    var route_id:Int?
    var status_code:String?
    var info:String?
    var created_by:Int?
    var created_at:String?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        route_id <- map["route_id"]
        status_code <- map["status_code"]
        info <- map["info"]
        created_by <- map["created_by"]
        created_at <- map["created_by"]

    }
}

//MARK: - ResponseGetRouteList
class ResponseGetRouteList: BaseModel {
    
    class Meta: BaseModel {
        var current_page:Int = 1
        var count:Int = 0
        var per_page:Int = 1
        var total:Int = 0
        var total_pages = 0
        
        required init?(map: Map) {
            super.init()
        }
        override func mapping(map: Map) {
            current_page <- map["current_page"]
            count <- map["count"]
            per_page <- map["per_page"]
            total <- map["total"]
            total_pages <- map["total_pages"]
        }
    }
    
    var data:[Route]?
    var meta:Meta?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        data <- map["data"]
        meta <- map["meta"]
    }
}


//MARK: - Route
class Route: BaseModel {
    
    enum RouteStatus:String {
        case New = "OP"
        case InProgess = "IP"
        case Finished = "DV"
        case Canceled = "CC"
    }
  
    var  id = -1
    var  truckId = -1
    var  driverId = -1
    var  tanker_id = -1
    var  status_id = -1
    var  auto_status = -1
    var  driver:UserModel.UserInfo?
    var  truck:Truck?
    var  tanker:Tanker?
    var  status:Status?
    var  tracking:[Tracking]?
    var  totalOrders = -1
    var  truckFloorCap = ""
    var  date = ""
    var  start_time = ""
    var  end_time = ""
    var  driver_name = ""
    var  shop_name = ""
    var  route_number = 0
    var  route_name_sts = ""
    var  orderList:[Order] = []
    var totalTimeEst = 0
    var totalDistance = ""
    var locationList:[Address] = []
    var notes:[Note] = []
    
    
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id          <- map["id"]
        truckId     <- map["truck_id"]
        driverId    <- map["driver_id"]
        truckFloorCap <- map["truck_floor_cap"]
        date        <- map["date"]
        status      <- map["status"]
        orderList   <- (map["order_list"])
        route_number <- map["route_number"]
        route_name_sts <- map["route_name_sts"]
        start_time <- map["start_time"]
        driver_name <- map["driver_name"]
        end_time <- map["end_time"]
        shop_name <- map["shop_name"]
        orderList <- map["orders"]
        totalOrders <- map["orders_count"]
        tanker <- map["tanker"]
        truck <- map["truck"]
        tracking <- map["tracking"]
        driver <- map["driver"]
        totalTimeEst <- map["est_dur"]
        totalDistance <- map["est_dist"]
        locationList <- map["location_list"]
        notes <- map["notes"]
        orderList.forEach { (order) in
            order.driver_id = driver?.id ?? 0
        }
    }
    
    var isFirstStartOrder:Bool{
        get{
            var result = true
            for item in orderList{
                if item.statusOrder != .newStatus{
                   result = false
                    break
                }
            }
            
            return result
        }
    }
    
    lazy var routeStatus:RouteStatus = {
        switch E(status?.code){
        case "OP":
            return RouteStatus.New
        case "IP":
            return RouteStatus.InProgess
        case "DV":
            return RouteStatus.Finished
        case "CC":
            return RouteStatus.Canceled
        default:
            return RouteStatus.New
        }
    }()
    
    var  colorStatus:UIColor {
        get{
            
            switch E(status?.code) {
            case "OP":
                return AppColor.newStatus;
            case "IP":
                return AppColor.inProcessStatus;
            case "DV":
                return AppColor.deliveryStatus;
            case "CC":
                return AppColor.redColor;
            default:
                return AppColor.white;
            }
        }
    }
    
    var nameStatus:String {
        get{
        
            //self.updateStatusWhenOffline()
            
            switch E(status?.code) {
            case "OP":
                return "New".localized
            case "IP":
                return "In Progress".localized;
            case "DV":
                return "Finished".localized;
            case "CC":
                return "Cancelled".localized;
            default:
                return "Unknown";
            }
        }
    }
}

