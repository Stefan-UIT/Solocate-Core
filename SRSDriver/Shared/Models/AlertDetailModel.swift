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

    var alertMsg : String?
    var comment : AnyObject?
    var itemRef : AnyObject?
    var ntfTypeName : AnyObject?
    var refId : Int?
    var refType : String?
    var ruleTypeName : String?
    var sts : Int?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map)
    {
        alertMsg <- map["alert_msg"]
        comment <- map["comment"]
        itemRef <- map["item_ref"]
        ntfTypeName <- map["ntf_type_name"]
        refId <- map["ref_id"]
        refType <- map["ref_type"]
        ruleTypeName <- map["rule_type_name"]
        sts <- map["sts"]
    }
}
