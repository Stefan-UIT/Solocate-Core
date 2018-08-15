//
//  CoordinatorRouteModel.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/15/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

class CoordinatorRouteModel: BaseModel {
    
    var coordinator:[Route]?
    var driversdrivers:[Route]?
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        coordinator <- map["coordinator"]
        driversdrivers <- map["driversdrivers"]
    }
}
