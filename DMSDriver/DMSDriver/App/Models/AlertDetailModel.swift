//
//  AlertDetailModel.swift
//  DMSDriver
//
//  Created by MrJ on 5/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper

class AlertDetailModel: NSObject, Mappable {

    var id : Int?
    var alertMsg : String?
    var refId : Int?
    var refType : String?
    var sts : Int?
    var orderStsName : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        alertMsg <- map["alert_msg"]
        refId <- map["ref_id"]
        refType <- map["ref_type"]
        sts <- map["sts"]
        orderStsName <- map["order_sts_name"]
    }
}
