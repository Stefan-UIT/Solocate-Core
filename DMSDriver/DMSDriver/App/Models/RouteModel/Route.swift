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
class Tanker: Truck { }
class Status: BasicModel { }
class Urgency: BasicModel { }
class Company: BasicModel { }
class Zone: BasicModel {
    var companyId:Int? = -1
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        companyId <- map["company_id"]
    }
}

class TruckType: BasicModel {
    var numberOfCompartments:Int? = -1
    var maxVol:String? = ""
    var tachograph:Int? = -1
    
    func isTachograph() -> Bool {
        let isTachograph = tachograph == 1 ? true : false
        return isTachograph
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        numberOfCompartments <- map["num_of_compartments"]
        maxVol <- map["max_vol"]
        tachograph <- map["tachograph"]
    }
}

class TankerJSON: BaseModel {
    var id:Int?
    var tanker:Tanker?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        tanker <- map["tanker"]
    }
}

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
    var isLiquidType:Bool {
        get {
            guard let routeTypeID = self.routeType?.id else { return false }
            return routeTypeID == RouteType.Liquid.rawValue
        }
    }
    
    var isPackedType:Bool {
        get {
            return !isLiquidType
        }
    }
    
    var numberOfPallets:Int = 0
    enum RouteType:Int {
        case Liquid = 1
        case Packed = 2
        
        var name: String {
            get {
                switch self {
                case .Liquid:
                    return "liquid".localized
                case .Packed:
                    return "packed".localized;
                }
            }
        }
        
        var code: String {
            get {
                switch self {
                case .Liquid:
                    return "LQ".localized
                case .Packed:
                    return "PK".localized;
                }
            }
        }
        
    }
    
    enum RouteStatus:String {
        case New = "OP"
        case InProgess = "IP"
        case Finished = "DV"
        case Canceled = "CC"
        case Draft = "DR"
        case Accepted = "AC"
        case Rejected = "RJ"
        
        var name: String {
            get {
                switch self {
                case .New:
                    return "New".localized
                case .InProgess:
                    return "in-progress".localized;
                case .Finished:
                    return "Finished".localized;
                case .Canceled:
                    return "Cancelled".localized;
                case .Draft:
                    return "Draft".localized
                case .Accepted:
                    return "Accepted-by-driver".localized
                case .Rejected:
                    return "Rejected-by-driver".localized
                }
            }
        }
        
        var id:Int {
            get {
                switch self {
                case .New:
                    return 1
                case .InProgess:
                    return 2
                case .Finished:
                    return 3
                case .Canceled:
                    return 4
                case .Draft:
                    return 5
                case .Accepted:
                    return 6
                case .Rejected:
                    return 7
                }
            }
        }
        
        func convertToStatus() -> Status {
            let result = Status()
            result.code = rawValue
            result.name = name
            result.id = id
            return result
        }
        
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
    var truckType:TruckType?
    var routeMaster:RouteMaster?
    var company:Company?
    var loadVolume:Int?
    var assignedInfo:[AssignedInfo]?
    var routeType:BasicModel?
    var routeTypeId:Int?
    var companySeqID:String?
    
    var isNewStatus:Bool {
        get {
            return status?.code == RouteStatus.New.rawValue
        }
    }
    
    var isRejectedStatus:Bool {
        get {
            return status?.code == RouteStatus.Rejected.rawValue
        }
    }
    
    
    // NEW
    var tankers:[Tanker]?
    var tankersJSON:[TankerJSON]?
    
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
    
    var trailerTankerNameCoreData: String = ""
    
    var trailerTankerName: String {
        get {
            if ReachabilityManager.isNetworkAvailable {
                var _trailerTankerName = ""
                for tanker in tankers ?? [] {
                    _trailerTankerName = _trailerTankerName == "" ? tanker.plateNumber : _trailerTankerName + ", " + tanker.plateNumber
                    _trailerTankerName = _trailerTankerName == "-" ? "" : _trailerTankerName
                }
                return _trailerTankerName
            } else {
                return trailerTankerNameCoreData
            }
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
    
    func routeTypeName() -> String {
        guard let _routeTypeName = routeType?.name else {
            return Route.RouteType(rawValue: routeTypeId ?? 0)?.name ?? ""
        }
        return _routeTypeName
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
        route_number <- map["route_number"]
        route_name_sts <- map["route_name_sts"]
        start_time <- map["start_time"]
        driver_name <- map["driver_name"]
        end_time <- map["end_time"]
        shop_name <- map["shop_name"]
        orderList <- map["shipping_orders"]
        totalOrders <- map["shipping_orders_count"]
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
        
        routeMaster <- map["route_master"]
        truckType <- map["truck_type"]
        company <- map["company"]
        loadVolume <- map["load_vol"]
        assignedInfo <- map["drivers"]
        tankers <- map["tankers"]
//        tankersJSON <- map["tankers"]
//        guard let array = tankersJSON else { return }
//
//        tankers = array.map({$0.tanker ?? Tanker()})
        routeType <- map["route_type"]
        routeTypeId <- map["route_type_id"]
        companySeqID <- map["comp_seq_id"]
        numberOfPallets <- map["number_of_pallets"]
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
            // remove empty name
            let arrayTemp = orderList.filter({$0.customer?.userName != nil && !$0.customer!.userName!.isEmpty })
           let array = arrayTemp.unique(map: {$0.customer!.userName})
            return array.map({$0.customer?.userName ?? ""})
        }
    }
    
    var consigneeNameArr:[String] {
        get {
            // remove empty name
            let arrayTemp = orderList.filter({$0.consigneeName != nil && !$0.consigneeName!.isEmpty })
            let array = arrayTemp.unique(map: {$0.consigneeName})
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
            case "OP", "AC", "DR":
                return AppColor.newStatus;
            case "IP":
                return AppColor.InTransit;
            case "DV":
                return AppColor.deliveryStatus;
            case "CC", "RJ":
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
    
    var startDate: Date {
        get {
            guard let _startDate = start_time.date else { return Date() }
            return _startDate
        }
    }
    
    var endDate: Date {
        get {
            guard let _endDate = end_time.date else { return Date() }
            return _endDate
        }
    }
}

