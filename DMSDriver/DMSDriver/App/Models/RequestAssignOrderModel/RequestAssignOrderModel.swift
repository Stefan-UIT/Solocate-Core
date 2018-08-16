//
//  RequestAssignOrderModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/16/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class RequestAssignOrderModel: BaseModel {

    var order_ids:[String] = []
    var driver_id:Int?
    var date:String?
    
    override init() {
        //
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        order_ids <- map["order_ids"]
        driver_id <- map["driver_id"]
        date <- map["date"]
    }
}
