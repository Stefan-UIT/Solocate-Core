//
//  BusinessOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

enum BusinessOrderLocationType: String {
    case Pickup = "PK"
    case Warehouse = "WH"
    case Customer = "CS"
}

enum BusinessOrderType: String {
    case Pickup = "Pick Up"
    case Delivery =  "Delivery"
    
    var typeId: Int {
        switch self {
        case .Pickup:
            return 2
        case .Delivery:
            return 1
        }
    }
}

enum BusinessOrderInfoRow: Int {
    case ORDER_TYPE = 0
    case CUSTOMER
    case DUE_DATE
    case REMARK
}

enum BusinessOrderAddressInfoRow: Int {
    case ADDRESS = 0
    case FLOOR
    case APARTMENT
    case NUMBER
    case OPEN_TIME
    case CLOSE_TIME
    case CONSIGNEE_NAME
    case CONSIGNEE_PHONE
}

enum BusinessOrderSKUInfoRow: Int {
    case SKU = 0
    case QUANTITY
    case UOM
    case BATCH_ID
}

enum RequireRow {
    case OrderType
    case Customer
    case DueDate
    case SKU
    case Quantity
    case UOM
    case Address
    case OpenTime
    case CloseTime
    case None
}

enum BusinessOrderStatusCode: String {
    case New = "OP"
    case PartialLoaded = "PL"
    case Loaded = "LD"
    case InProgress = "IP"
    case PartialDelivered = "PD"
    case Delivered = "DV"
    case Cancelled = "CC"
    
    var statusName: String {
        switch self {
        case .New:
            return "New".localized
        case .PartialLoaded:
            return "Partial-Loaded".localized
        case .Loaded:
            return "Loaded".localized
        case .InProgress:
            return "in-progress".localized
        case .PartialDelivered:
            return "partial-delivered".localized
        case .Delivered:
            return "Delivered".localized
        case .Cancelled:
            return "Cancelled".localized
        }
    }
    
    var color:UIColor {
        get {
            switch self {
            case .New:
                return AppColor.newStatus;
            case .InProgress:
                return AppColor.InTransit;
            case .Loaded, .PartialLoaded:
                return AppColor.mainColor
            case .Delivered, .PartialDelivered:
                return AppColor.deliveryStatus;
            case .Cancelled:
                return AppColor.redColor;
            }
        }
    }
    
    var code:Int {
        get {
            switch self {
            case .New:
                return 1
            case .PartialLoaded:
                return 2
            case .Loaded:
                return 3
            case .InProgress:
                return 4
            case .PartialDelivered:
                return 5
            case .Delivered:
                return 6
            case .Cancelled:
                return 7
            }
        }
    }
}

class BusinessOrderStatus: BasicModel { }
class BusinessOrder: Order {
    var divisionId:Int?
    var zoneId:Int?
    var referenceCode:String?
    var dueDate:String?
    var dueDateFrom: String?
    var dueDateTo: String?
    var customerBO:CustomerModel?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        divisionId <- map["division_id"]
        zoneId <- map["zone_id"]
        referenceCode <- map["ref_code"]
        dueDate <- map["due_dt"]
        status <- map["business_status"]
        typeID <- map["business_type_id"]
        zone <- map["business_zone"]
        from <- map["business_from"]
        to <- map["business_to"]
        division <- map["business_division"]
        customer <- map["business_customer"]
        details <- map["business_details"]
        dueDateFrom <- map["due_dt_from"]
        dueDateTo <- map["due_dt_to"]
    }
    
    func isRequireEdit(_ content: String?,_ requireSection: RequireRow) -> Bool {
        if content?.isEmpty == true || (content == nil) {
            switch requireSection {
            case .OrderType:
                return true
            case .Customer:
                return true
            case .DueDate:
                return true
            case .SKU:
                return true
            case .Quantity:
                return true
            case .UOM:
                return true
            case .Address:
                return true
            case .OpenTime:
                return true
            case .CloseTime:
                return true
            case .None:
                return false
            }
        } else {
            return false
        }
    }
}

class ZoneModel:BasicModel { }
