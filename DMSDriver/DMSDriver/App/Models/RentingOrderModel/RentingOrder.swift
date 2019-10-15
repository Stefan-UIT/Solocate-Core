//
//  RentingOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

enum RentingOrderStatusCode: String {
    case NewStatus = "OP"
    case PartlyAssigned = "PA"
    case FullyAssigned = "FA"
    case InProgress = "IP"
    case Finished = "FH"
    case Cancelled = "CC"
    
    var statusName: String {
        switch self {
        case .NewStatus:
            return "New".localized
        case .PartlyAssigned:
            return "partly-assigned".localized
        case .FullyAssigned:
            return "fully-assigned".localized
        case .InProgress:
            return "in-progress".localized
        case .Finished:
            return "Finished".localized
        case .Cancelled:
            return "Cancelled".localized
        }
    }
    
    var color:UIColor {
        get {
            switch self {
            case .NewStatus, .PartlyAssigned:
                return AppColor.newStatus;
            case .InProgress:
                return AppColor.InTransit;
            case .FullyAssigned:
                return AppColor.mainColor
            case .Finished:
                return AppColor.deliveryStatus;
            case .Cancelled:
                return AppColor.redColor;
            }
        }
    }
    
    var code:Int {
        get {
            switch self {
            case .NewStatus:
                return 1
            case .PartlyAssigned:
                return 2
            case .FullyAssigned:
                return 3
            case .InProgress:
                return 4
            case .Finished:
                return 5
            case .Cancelled:
                return 6
            }
        }
    }
}
//MARK: RENTING
class RentingOrderCompany: BasicModel { }
class RentingOrderStatus: BasicModel { }

class RentingOrder: BaseModel {
    
    class RentingOrderSKU: BaseModel {
        var id:Int?
        var name:String?
        var referenceCode:String?
        var materialId:String?
        var unitTypeId:String?
        var ac:String?
        var companyId:Int?
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            referenceCode <- map["ref_cd"]
            materialId <- map["material_id"]
            unitTypeId <- map["unit_type_id"]
            ac <- map["ac"]
            companyId <- map["company_id"]
        }
    }
    
    class RentingOrderDetail: BaseModel {
        struct RentingTruckType:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            var fuelType:String?
            var numberOfCompartments:Int?
            var maxVol:String?
            var tachograph:Int?
            var companyId:Int?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["code"]
                fuelType <- map["fuel_type"]
                numberOfCompartments <- map["num_of_compartments"]
                maxVol <- map["max_vol"]
                tachograph <- map["tachograph"]
                companyId <- map ["company_id"]
            }
        }
        
        struct RentingTruck:Mappable {
            var id:Int?
            var typeId:String?
            var driverId:String?
            var maxWeight:Int?
            var selfWeight:Int?
            var maxVol:Int?
            var plateNum:String?
            var companyId:Int?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                typeId <- map["type_id"]
                driverId <- map["driver_id"]
                maxWeight <- map["max_weight"]
                selfWeight <- map["self_weight"]
                maxVol <- map["max_vol"]
                plateNum <- map["plate_num"]
                if plateNum == nil {
                    plateNum <- map["plate_number"]
                }
                companyId <- map["company_id"]
            }
        }
        
        struct RentingTanker:Mappable {
            var tankers:[RentingTruck]?
            var tankerType:[RentingTruckType]?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                tankers <- map["tankers"]
                tankerType <- map["tanker_type"]
            }
        }
        
        var id = -1
        var rentingOrderID = -1
        var truckTypeId = -1
        var truckId = -1
        var truckType:RentingTruckType?
        var truck:RentingTruck?
        var driver:UserModel.UserInfo?
        var sku:[RentingOrderSKU]?
        var tanker:RentingTanker?
        var driverId = -1
        // NEW
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            rentingOrderID <- map["renting_order_id"]
            truckTypeId <- map["truck_type_id"]
            truckId <- map["truck_id"]
            truckType <- map["truck_type"]
            truck <- map["truck"]
            driver <- map["driver"]
            sku <- map["sku"]
            tanker <- map["tanker"]
            driverId <- map["driver_id"]
        }
        
        var skulist: String {
            get {
                var _skuList = ""
                for each in 0..<(sku?.count ?? 0){
                    _skuList = _skuList == "" ? (sku?[each].name ?? "") : _skuList + ", " + (sku?[each].name ?? "")
                }
                return _skuList
            }
        }
        
    }
    
    var id = -1
    var referenceCode = ""
    var customerId = -1
    var startDate:String?
    var endDate:String?
    var truckTypeId = -1
    var truckQty:Int?
    var rentingOrderStatusId = -1
    var companyId = -1
    var createdBy = -1
    var updatedBy = -1
    var createdAt:String?
    var updatedAt:String?
    var rentingOrderTrucks:[Truck?] = []
    var rentingOrderDrivers:[UserModel.UserInfo?] = []
    var rentingOrderTankers:[Tanker?] = []
    var rentingOrderStatus:RentingOrderStatus?
    var rentingOrderCustomer:UserModel.UserInfo?
    var rentingOrderTruckType:TruckType?
    var rentingOrderSKUs:[RentingOrderSKU]?
    var rentingOrderCompany:RentingOrderCompany?
    var rentingOrderDetails:[RentingOrderDetail]?
//    var renting_order_creator:UserModel.UserInfo?
    
    var trailerTankers: String {
        get {
            var _trailerTankers = ""
            for trailerTanker in rentingOrderTankers {
                _trailerTankers = _trailerTankers == "" ? (trailerTanker?.name ?? "") : _trailerTankers + ", " + (trailerTanker?.name ?? "")
            }
            return _trailerTankers
        }
    }
    
    var rentingOrderStatusColor: UIColor {
        get {
            let _rentingOrderStatus = RentingOrderStatusCode(rawValue: rentingOrderStatus?.code ?? "")
            return _rentingOrderStatus?.color ?? AppColor.mainColor
        }
    }
    
    var skusName: String {
        get {
            var _skusName = ""
            for skuName in rentingOrderSKUs ?? [] {
                _skusName = _skusName == "" ? (skuName.name ?? "") : _skusName + ", " + (skuName.name ?? "")
            }
            return _skusName
        }
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        referenceCode <- map["ref_cd"]
        customerId <- map["cus_id"]
        startDate <- map["from_dt"]
        endDate <- map["to_dt"]
        truckTypeId <- map["truck_type_id"]
        truckQty <- map["truck_qty"]
        rentingOrderStatusId <- map["renting_order_status_id"]
        companyId <- map["company_id"]
        createdBy <- map["created_by"]
        updatedBy <- map["updated_by"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
//        rentingOrderTrucks <- map["renting_order_trucks"]
//        rentingOrderDrivers <- map["renting_order_drivers"]
//        rentingOrderTankers <- map["renting_order_tankers"]
        rentingOrderStatus <- map["renting_order_status"]
        rentingOrderCustomer <- map["renting_order_customer"]
//        rentingOrderTruckType <- map["renting_order_truck_type"]
//        rentingOrderSKUs <- map["renting_order_skus"]
        rentingOrderCompany <- map["renting_order_company"]
//        renting_order_creator <- map["renting_order_creator"]
        rentingOrderDetails <- map["renting_order_details"]
    }
}

