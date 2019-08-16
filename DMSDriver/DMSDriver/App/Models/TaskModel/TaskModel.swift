//
//  TaskModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 10/22/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

enum TaskStatus: String {
    case open = "OP"
    case pickedUp = "PU"
    case delivered = "DV"
    case inprogress = "IP"
    case missingInTruck = "MT"
    case missingAnPickUP = "MP"
    case cancel = "CC"
    
    var statusName: String {
        switch self {
        case .open:
            return "New".localized
        case .inprogress:
            return "in-progress".localized
        case .delivered:
            return "Delivered".localized
        case .cancel:
            return "Cancelled".localized
        case .pickedUp:
            return "picked-up".localized
        case .missingInTruck:
            return "missing-in-trunk".localized
        case .missingAnPickUP:
            return "missing-at-pick-up".localized
        }
    }
}

class TaskModel: BaseModel {
    
    var id:Int = -1
    var status:Status!
    var assignee:UserModel.UserInfo!
    var urgency:Urgency!
    var address:Address!
    var name = ""
//    var driver_id:Int?
//    var driver_name:String?
//    var client_name:String?
    var customer_name:String?
    var instructions:String?
//    var urgent_type_code:String?
    var courier_3rd:String?
    var coord_phone:String?
    var rcvr_name:String?
    var rcvr_phone:String?
    var collect_call:String?
    var rcvd_day:String?
//    var full_addr:String?
//    var lattd:String?
//    var lngtd:String?
//    var state:String?
//    var city:String?
//    var zip:String?
    var dlvy_start_time:String?
    var dlvy_end_time:String?
//    var urgent_type_id:Int = 0
//    var urgent_type_name_en:String?
//    var urgent_type_name_hb:String?
    var dlvy_date:String?
    var created_at:String?
    var dlvd_dt:String?
    var reason:Reason?
    var reason_msg = ""

    
    var colorUrgent:UIColor{
        get{
            switch urgency.name {
            case "Medium":
                return AppColor.medium
            case  "High":
                return AppColor.high
            default:
                return AppColor.normal
            }
        }
    }
    
    var colorStatus:UIColor {
        get{
            let sts = StatusOrder(rawValue: (status.code ?? "")) ?? StatusOrder.newStatus
            return sts.color
        }
    }

    var location:CLLocationCoordinate2D {
        get {
            let longitude = address.lngtd?.doubleValue ?? 0
            let  latitude = address.lattd?.doubleValue ?? 0
            
            return CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
        }
    }
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        status <- map["status"]
        assignee <- map["assignee"]
        urgency <- map["urgency"]
        address <- map["address"]
//        driver_id <- map["driver_id"]
//        driver_name <- map["driver_name"]
//        client_name <- map["client_name"]
        customer_name <- map["customer_name"]
        instructions <- map["instruction"]
//        urgent_type_code <- map["urgent_type_code"]
//        courier_3rd <- map["courier_3rd"]
//        coord_phone <- map["coord_phone"]
//        rcvr_name <- map["rcvr_name"]
//        rcvr_phone <- map["rcvr_phone"]
//        collect_call <- map["collect_call"]
//        rcvd_day <- map["rcvd_day"]
//        full_addr <- map["full_addr"]
//        lattd <- map["lattd"]
//        lngtd <- map["lngtd"]
//        state <- map["state"]
//        city <- map["city"]
//        zip <- map["zip"]
        dlvy_start_time <- map["start_time"]
        dlvy_end_time <- map["end_time"]
//        task_status_name <- map["task_status_name"]
//        urgent_type_name_en <- map["urgent_type_name_en"]
//        urgent_type_name_hb <- map["urgent_type_name_hb"]
//        dlvy_date <- map["dlvy_date"]
        created_at <- map["created_at"]
//        dlvd_dt <- map["dlvd_dt"]
//        reason <- map["reason"]
//        reason_msg <- map["reason_msg"]
        
    }
    
    func toReturnedItems() -> ReturnedItem {
        let json = self.toJSON()
        return ReturnedItem(JSON: json)!
    }
}

class ReturnedItem: TaskModel {
    var totalQuantity:Int?
    var returnedQuantity:Int?
    var warehouse:Warehouse?
    var assignees:[UserModel.UserInfo] = []
    var routeID:Int?
    var note:String?
    var currentAssignee:UserModel.UserInfo!
    var myOwn:UserModel.UserInfo!
    var isAllowedToActions:Bool {
        get {
            return currentAssignee.id == myOwn.id && !(isFinished || isCancelled)
        }
    }
    
    var isAllowedToUpdateReturnedItemTextField:Bool {
        return isAllowedToActions && isRampManagerMode
    }
    
    var isFinished:Bool {
        return status.code == TaskStatus.delivered.rawValue
    }
    
    var isCancelled:Bool {
        return status.code == TaskStatus.cancel.rawValue
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        totalQuantity <- map["qty"]
        returnedQuantity <- map["dlvd_qty"]
        warehouse <- map["warehouse"]
        assignees <- map["assignees"]
        note <- map["note"]
        routeID <- map["route_id"]
        currentAssignee <- map["current_assignee"]
        myOwn <- map["my_own"]
    }
}
