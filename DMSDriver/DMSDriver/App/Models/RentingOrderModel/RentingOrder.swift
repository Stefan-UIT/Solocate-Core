//
//  RentingOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

enum StatusRentingOrder: String {
    case newStatus = "OP"
    case InTransit = "IT"
    case InProgress = "IP"
    case deliveryStatus = "DV"
    case CancelStatus = "CC"
    case UnableToFinish = "UF"
    case PickupStatus = "PU"
    case Loaded = "LD"
    case WarehouseClarification = "WC"
    case PartialLoaded = "PL"
    case PartialDelivered = "PD"
    
    var statusName: String {
        switch self {
        case .newStatus:
            return "New".localized
        case .InTransit:
            return "in-transit".localized
        case .InProgress:
            return "in-progress".localized
        case .PickupStatus:
            return "picked-up".localized
        case .deliveryStatus:
            return "Delivered".localized
        case .CancelStatus:
            return "Cancelled".localized
        case .UnableToFinish:
            return "unable-to-finish".localized
        case .Loaded:
            return "loaded".localized
        case .PartialLoaded:
            return "partial-loaded".localized
        case .PartialDelivered:
            return "partial-delivered".localized
        case .WarehouseClarification:
            return "warehouse-clarification".localized
        }
    }
    
    var color:UIColor {
        get {
            switch self {
            case .newStatus, .Loaded, .PartialLoaded:
                return AppColor.newStatus;
            case .InTransit, .InProgress:
                return AppColor.InTransit;
            case .deliveryStatus, .PartialDelivered:
                return AppColor.deliveryStatus;
            case .CancelStatus,
                 .UnableToFinish:
                return AppColor.redColor;
            case .WarehouseClarification:
                return AppColor.orangeColor
            default:
                return AppColor.newStatus;
            }
        }
    }
}
//MARK: RENTING
class RentingOrderCompany: BasicModel { }
class RentingOrderStatus: BaseModel {
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
        code <- map["cd"]
    }
}

class RentingOrder: BaseModel {
    
    class RentingOrderSKU: Order.Detail {
        var referenceCode:String?
        var materialId:String?
        var unitTypeId:String?
        var ac:String?
        var companyId:Int?
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            referenceCode <- map["ref_cd"]
            materialId <- map["material_id"]
            unitTypeId <- map["unit_type_id"]
            ac <- map["ac"]
            companyId <- map["company_id"]
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
//    var renting_order_creator:UserModel.UserInfo?
    
    var trailerTankers: String {
        get {
            var _trailerTankers = ""
            for trailerTanker in rentingOrderTankers {
                _trailerTankers = _trailerTankers == "" ? "" : _trailerTankers + ", " + (trailerTanker?.name ?? "")
            }
            return _trailerTankers
        }
    }
    
    var skusName: String {
        get {
            var _skusName = ""
            for skuName in rentingOrderSKUs ?? [] {
                _skusName = _skusName == "" ? "" : _skusName + ", " + (skuName.name ?? "")
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
        rentingOrderTrucks <- map["renting_order_trucks"]
        rentingOrderDrivers <- map["renting_order_drivers"]
        rentingOrderTankers <- map["renting_order_tankers"]
        rentingOrderStatus <- map["renting_order_status"]
        rentingOrderCustomer <- map["renting_order_customer"]
        rentingOrderTruckType <- map["renting_order_truck_type"]
        rentingOrderSKUs <- map["renting_order_skus"]
        rentingOrderCompany <- map["renting_order_company"]
//        renting_order_creator <- map["renting_order_creator"]
    }
}

