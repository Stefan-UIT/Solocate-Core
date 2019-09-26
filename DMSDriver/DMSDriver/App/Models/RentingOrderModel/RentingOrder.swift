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

class RentingOrder: BaseModel {
    var rentingOrderId:Int?
    var refCode:Int?
    var rentingStatus:StatusRentingOrder?
    var customerName:String?
    var startDate:String?
    var endDate:String?
    var truckType:Truck?
    var trailerTankerType:String?
    var skus = [Order.Detail]()
    var skusName:String {
        get {
            var skusText = ""
            let counting = self.skus.count
            for index in 0 ..< counting {
                skusText = skusText + (self.skus[index].name ?? "")
                if index == counting-1 {
                    skusText = skusText + "."
                } else {
                    skusText = skusText + ", "
                }
            }
            return skusText
        }
    }
    
    var status: Status?
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
            return E(status?.name).localized
        }
    }
    
    var statusOrder:StatusRentingOrder{
        get{
            return StatusRentingOrder(rawValue: E(status?.code)) ?? .newStatus
        }
    }
}

