//
//  AlertDetailModel.swift
//  DMSDriver
//
//  Created by MrJ on 5/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

enum StatusAlert:Int {
    case open = 1
    case resolved
}

class AlertModel: BaseModel {
    
    struct RuleType:Mappable {
        var id:Int?
        var name:String?
        var code:String?
        var active:Int?
        var created_by:Int?
        var updated_by:Int?
        var created_at:String?
        var updated_at:String?
        
        init?(map: Map) {
            //
        }
        
        mutating func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            code <- map["code"]
            active <- map["active"]
            created_by <- map["created_by"]
            updated_by <- map["updated_by"]
            created_at <- map["created_at"]
            updated_at <- map["updated_at"]
        }
    }

    var alert_msg : String?
    var ref_id : Int?
    var ref_type : String?
    var ntf_type : Int?
    var status : Int?
    var comment:String?
    var statusName:String?
    var routeId:Int?
    var driverId:Int?
    var driverName:String?
    var truckName:String?
    var tankerName:String?
    var ruleType:RuleType?
    var created_at:String?
    var alertId:Int?
    
    var statusAlert:StatusAlert{
        get{
            return StatusAlert(rawValue: status ?? 0) ?? .open
        }
    }

    var colorStatus:UIColor {
        get{
            switch statusAlert {
            case .open:
                return AppColor.newStatus;
            case .resolved:
                return AppColor.deliveryStatus;
            }
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map){
        alert_msg <- map["alert_msg"]
        ref_id <- map["ref_id"]
        ref_type <- map["ref_type"]
        ntf_type <- map["ntf_type"]
        status <- map["sts"]
        statusName <- map["sts_name"]
        comment <- map["comment"]
        routeId <- map["route_id"]
        driverId <- map["driver_id"]
        driverName <- map["driver_name"]
        ruleType <- map["rule_type"]
        created_at <- map["created_at"]
        truckName <- map["truck_name"]
        tankerName <- map["tanker_name"]
        alertId <- map["alert_id"]
        
        if alertId == nil { // use for get alert detail (alertId is id)
            alertId <- map["id"]
        }
    }
}


class AlertFilterModel: BaseModel {

    var driver_name : String?
    var sts : Int?
    var created_day_from : String?
    var created_day_to : String?
    var sts_name : String?
    var rule_id : String?
    var route_id : String?
    var created_day : String?
    
    var page = 1

    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map){
        driver_name <- map["driver_name"]
        sts <- map["sts"]
        created_day_from <- map["created_day_from"]
        created_day_to <- map["created_day_to"]
        sts_name <- map["sts_name"]
        rule_id <- map["rule_id"]
        route_id <- map["route_id"]
        created_day <- map["created_day"]
    }
}
