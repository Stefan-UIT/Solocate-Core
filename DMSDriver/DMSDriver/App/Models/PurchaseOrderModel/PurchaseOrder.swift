//
//  PurchaseOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 12/16/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import Foundation
import ObjectMapper

class PurchaseOrder: Order {
    var divisionId:Int?
    var zoneId:Int?
    var referenceCode:String?
    var dueDate:String?
    
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
        status <- map["purchase_status"]
        orderType <- map["purchase_type"]
        zone <- map["purchase_zone"]
        from <- map["purchase_from"]
        to <- map["purchase_to"]
        division <- map["purchase_division"]
        customer <- map["purchase_customer"]
        details <- map["purchase_details"]
    }
}
