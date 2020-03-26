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

enum BusinessOrderCOD: String {
    case YES = "Yes"
    case NO =  "No"
    
    var id: Int {
        switch self {
        case .NO:
            return 0
        case .YES:
            return 1
        }
    }
}

enum BusinessOrderInfoRow: Int {
    case ORDER_TYPE = 0
    case CUSTOMER
    case DUE_DATE_FROM
    case DUE_DATE_TO
    case COD
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
    case START_TIME
    case END_TIME
    case ZONE
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
    case Zone
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
    var customerId: String?
    var customerLocationId: String?
    var wareHouseId: String?
    var cod:Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <- map["id"]
        divisionId <- map["division_id"]
        zoneId <- map["zone_id"]
        referenceCode <- map["ref_code"]
        status <- map["purchase_status"]
        typeID <- map["purchase_type_id"]
        zone <- map["purchase_zone"]
        from <- map["purchase_from"]
        to <- map["purchase_to"]
        division <- map["purchase_division"]
        customer <- map["purchase_customer"]
        details <- map["purchase_details"]
        customerId <- map["cus_id"]
        customerLocationId <- map["cus_loc_id"]
        wareHouseId <- map["whs_id"]
        cod <- map["cod"]
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
            case .Zone:
                return true
            case .None:
                return false
            }
        } else {
            return false
        }
    }
}

