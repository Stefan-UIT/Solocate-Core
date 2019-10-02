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
class TruckType: BasicModel { }
class Tanker: BasicModel { }
class Status: BasicModel { }
class Urgency: BasicModel { }
class Company: BasicModel { }

//MARK: - Status
class BasicModel: BaseModel {
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
        if code == nil {
            code <- map["cd"]
        }
    }
}

class Warehouse: BasicModel {
    
    var contactName:String?
    var address:String?
    var phone:String?
    var email:String?
    var longitude:String?
    var latitude:String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        contactName <- map["ctt_name"]
        address <- map["address"]
        phone <- map["phone"]
        email <- map["email"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
    }
}

class RouteMaster: BasicModel {
    var warehouse:Warehouse?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        warehouse <- map["warehouse_location"]
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
//    var  truck:Truck?
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
    var truckType:TruckType?
    var routeMaster:RouteMaster?
    var company:Company?
    var loadVolume:String = "0.0"
    var assignedInfo:[AssignedInfo]?
    
    
    // NEW
    
    
    var isAllowedGoToDelivery:Bool {
        get {
            let deliveryOrders = orderList.filter({$0.isDeliveryType})
            let newOrders = deliveryOrders.filter({$0.isNewStatus})
            return newOrders.count == 0
        }
    }
    
    var isAssignedDriver:Bool {
        get {
            guard let info = assignedInfo?.first else { return false}
            return (info.driverID != nil || info.driver != nil)
        }
    }
    
    var isAssignedTruck:Bool {
        get {
            guard let info = assignedInfo?.first else { return false}
            return (info.truckID != nil || info.truck != nil)
        }
    }
    
    func sortbyCustomerLocation() -> [Order] {
        var result = [Order]()
        for loc in locationList {
            let array = orderList.filter({$0.customerLocation?.lngtd == loc.lngtd && $0.customerLocation?.lattd == loc.lattd})
                result.append(array)
        }
    
        return result
    }
    
    func order(orderID:Int) -> Order? {
//        let array = orderList.filter({orderID == $0.id})
//        let order = array.first
        if let i = orderList.firstIndex(where: { orderID == $0.id }) {
            return orderList[i]
        }
        return nil
    }
    
    func updateOrder(orderID:Int, toStatus status:Status) {
        let order = self.order(orderID:orderID)
        order?.status = status
    }
    
    class AssignedInfo: BaseModel {
        var id:Int?
        var routeID:Int?
        var driverID:Int?
        var truckID:Int?
        var driver:Driver?
        var truck:Truck?
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            routeID <- map["route_id"]
            driverID <- map["driver_id"]
            truckID <- map["truck_id"]
            driver <- map["driver"]
            truck <- map["truck"]
            
        }
    }
    
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
//        truck <- map["truck"]
        tracking <- map["tracking"]
        driver <- map["driver"]
        totalTimeEst <- map["est_dur"]
        totalDistance <- map["est_dist"]
        locationList <- map["location_list"]
        notes <- map["notes"]
        orderList.forEach { (order) in
            order.driver_id = driver?.id ?? 0
        }
        
        routeMaster <- map["route_master"]
        truckType <- map["truck_type"]
        company <- map["company"]
        loadVolume <- map["load_vol"]
        assignedInfo <- map["drivers"]
    }
    
    var ordersAbleToLoad:[Order] {
        get {
            let filteredArray = orderList.filter({$0.isDeliveryType})
//            return filteredArray.filter({$0.statusOrder == StatusOrder.newStatus || $0.statusOrder == StatusOrder.WarehouseClarification})
            return filteredArray.filter({$0.statusOrder == StatusOrder.newStatus})
        }
    }
    
    var ordersGroupByCustomer:[Order] {
        get {
            return sortbyCustomerLocation()
        }
    }
    
    var customerNameArr:[String] {
        get {
           let array = orderList.unique(map: {$0.customer!.userName})
            return array.map({$0.customer?.userName ?? ""})
        }
    }
    
    var consigneeNameArr:[String] {
        get {
            let array = orderList.unique(map: {$0.consigneeName})
            return array.map({$0.consigneeName ?? ""})
        }
    }
    
    var isHasOrderNeedToBeLoaded:Bool {
        get {
            return ordersAbleToLoad.count > 0
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
    
    var routeStatus:RouteStatus {
        get {
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
        }
    }
    
    var  colorStatus:UIColor {
        get{
            
            switch E(status?.code) {
            case "OP":
                return AppColor.newStatus;
            case "IP":
                return AppColor.InTransit;
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
                return "in-progress".localized;
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

