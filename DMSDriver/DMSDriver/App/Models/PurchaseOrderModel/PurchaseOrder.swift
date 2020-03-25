//
//  PurchaseOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

enum PurchaseOrderStatusCode: String {
    case New = "OP"
    case InProgress = "IP"
    case PartialDelivered = "PD"
    case Delivered = "DV"
    case Cancelled = "CC"
    
    var statusName: String {
        switch self {
        case .New:
            return "New".localized
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
//            case .PartialDelivered:
//                return AppColor.mainColor
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
            case .InProgress:
                return 2
            case .PartialDelivered:
                return 3
            case .Delivered:
                return 4
            case .Cancelled:
                return 5
            }
        }
    }
}
class PurchaseOrderStatus: BasicModel { }
class PurchaseOrder: Order {
    var divisionId:Int?
    var zoneId:Int?
    var referenceCode:String?
    
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
    }
}
